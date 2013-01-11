class Village < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps
	include Ohm::Locking
	include OhmExtension

	attribute :name
	attribute :x, 									Type::Integer
	attribute :y, 									Type::Integer
	attribute :index, 							Type::Integer

	attribute :wood,								Type::Integer
	attribute :wood_max, 						Type::Integer
	attribute :stone, 							Type::Integer
	attribute :stone_max,						Type::Integer

	attribute :under_attack, 				Type::Boolean
		

	attribute :player_id, 					Type::Integer
	attribute :country_index,				Type::Integer

	attribute :strategy_id

	collection :buildings, 					Building
	collection :dinosaurs, 					Dinosaur

	index :name
	unique :index
	index :x
	index :y
	index :country_index

	# 获取村庄所属的玩家
	def player
		Player[player_id]
	end

	def player_name
		db.hget("Player:#{player_id}", :nickname)
	end

	def level
		case player.level
		when 1..10
			1
		when 11..20
			2
		when 21..30
			3
		else
			1
		end
	end

	def to_hash(*args)
		hash = {
			:id => id.to_s,
			:name => name,
			:x => x,
			:y => y,
			:resources => resources,
			:country_index => country_index
		}

		options = if args.include?(:all)
			args + [:strategy, :buildings_with_harvest]
		else
			args
		end

		options.each do |arg|
			case arg
			when :buildings
				hash[:buildings] = buildings.to_a.map(&:update_status!).map(&:to_hash)
			when :buildings_with_harvest
				hash[:buildings] = buildings.to_a.map(&:update_status!).map { |b| b.to_hash(:harvest_info) }
			when :strategy
				hash[:strategy] = strategy.try(:to_hash)
			end
		end

		hash
	end

	def resources
		warehouse_size = player.tech_warehouse_size
		{
			:wood => wood,
			:wood_max => warehouse_size,
			:stone => stone,
			:stone_max => warehouse_size
		}
	end

	[:spend, :receive].each do |name|
		define_method("#{name}!") do |args = {}|
			db.multi do |t|
				args.each do |att, val|
					if att.in?(:wood, :stone)
						return false if send(att) < val
						v = name == :spend ? -val : val
						t.hincrby(self.key, att, v)
					end
				end
			end
			load!
		end
	end

	# def create_building(building_type, level = 1, x, y, st)
	# 	Building.create :type => building_type.to_i, :level => level, :village_id => id, :x => x, :y => y, :status => st
	# end

	# args = { :type => 1, :level => 1, :x => 20, :y => 20, :status => 0, :has_worker => 0 }
	def create_building(args = {})
		args_dup = args.dup
		args_dup.merge!(:level => 1) if args[:level].nil?

		Building.create args_dup.merge(:village_id => id)
	end

	def full_info
		self.to_hash.merge(:buildings => buildings.to_a, :dinosaurs => dinosaurs.to_a)
	end

	def strategy
		Strategy[strategy_id]
	end

	def technology_ids
		db.smembers("Technology:indices:player_id:#{player_id}")
	end

	# Always return a Technology instance.
	def find_tech_by_type(tech_type)
		return nil if not tech_type.in?(Technology.types)

		tech = self.player.technologies.find(:type => tech_type).first
		if tech.nil?
			tech = Technology.create :type => tech_type, :player_id => player_id, :level => 0
		end
		return tech
	end

	def update_warehouse
		wh_size = self.buildings.find(:type => Building.hashes[:warehouse]).size
		wh_size = wh_size < 1 ? 1 : wh_size
		tech = find_tech_by_type(Technology.hashes[:storing])
		tech_size = tech.info[:property][:resource_max]
		total_size = wh_size * tech_size
		self.wood_max = total_size
		self.stone_max = total_size
	end

	def update_warehouse!
		update_warehouse
		self.sets :wood_max 	=> wood_max,
							:stone_max 	=> stone_max
		self
	end

	def has_built_building?(building_type)
		result = buildings.find(:type => building_type)
		result.any? && result.max{ |b| b.level if b }.try(:status).to_i >= 2
	end

	def country
		if @country.nil?
			@country = Country[db.hget("Player:#{player_id}", :country_id)]
		end
		@country
	end

	protected

	def before_save
		if index.zero?
			self.index = x * Country::COORD_TRANS_FACTOR + y
		end
	end

	def before_create
		self.wood = 5000
		self.stone = 5000
	end

	def after_create
		creeps = Creeps.create :x => x - 2, :y => y - 2, :is_quest_monster => true, :type => 1, :player_id => player_id
		country.add_quest_monster(creeps.index)

		self.mutex do
			if buildings.find(:type => Building.hashes[:residential]).blank?
				create_building :type => Building.hashes[:residential],
												:level => 1,
												:x => 25,
												:y => 29,
												:status => Building::STATUS[:finished]
			end
		end
	end

	def after_delete
		self.buildings.map(&:delete)
	end
end
