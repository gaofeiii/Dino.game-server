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

	def type
		0
	end

	def player_name
		db.hget("Player:#{player_id}", :nickname)
	end

	def level
		(player.level / 10.0).ceil
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
			:wood_max => warehouse_size,
			:stone_max => warehouse_size
		}
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

	def defense_troops
		str = self.strategy
		if str
			str.dinosaur_ids.map do |d_id|
				dino = Dinosaur[d_id]
				if dino
					dino
				end
			end.compact
		else
			[]
		end
	end

	protected

	def before_save
		if index.zero?
			self.index = x + y * Country::COORD_TRANS_FACTOR
		end
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
				create_building :type => Building.hashes[:arena],
												:level => 1,
												:x => 33,
												:y => 36,
												:status => Building::STATUS[:finished]
			end
		end
	end

	def after_delete
		self.buildings.map(&:delete)
	end
end
