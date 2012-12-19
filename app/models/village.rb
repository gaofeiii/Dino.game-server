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
	attribute :basic_wood_inc,			Type::Integer
	attribute :wood_inc, 						Type::Integer
	attribute :wood_max, 						Type::Integer
	attribute :stone, 							Type::Integer
	attribute :basic_stone_inc,			Type::Integer
	attribute :stone_inc,						Type::Integer
	attribute :stone_max,						Type::Integer

	# =========== Expired attributes ============
	attribute :population, 					Type::Integer
	attribute :population_inc,			Type::Integer
	attribute :population_max,			Type::Integer
	# ===========================================
	
	attribute :update_resource_at, 	Type::Integer
		

	attribute :player_id, 					Type::Integer
	attribute :country_index,				Type::Integer

	attribute :strategy_id

	collection :buildings, 					Building
	collection :dinosaurs, 					Dinosaur
	collection :buffs, 							Buff


	index :name
	unique :index
	index :x
	index :y
	index :country_index

	# 获取村庄所属的玩家
	def player
		Player[player_id]
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
			args + [:buildings, :strategy]
		else
			args
		end

		options.each do |arg|
			case arg
			when :buildings
				hash[:buildings] = buildings.to_a.map(&:update_status!).map(&:to_hash)
			when :strategy
				hash[:strategy] = strategy.try(:to_hash)
			end
		end

		hash
	end

	def resources
		{
			:wood => wood,
			:basic_wood_inc => basic_wood_inc,
			:wood_inc => wood_inc,
			:wood_max => wood_max,
			:stone => stone,
			:basic_stone_inc => basic_stone_inc,
			:stone_inc => stone_inc,	
			:stone_max => stone_max,
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

	def create_building(building_type, level = 1, x, y, st)
		Building.create :type => building_type.to_i, :level => level, :village_id => id, :x => x, :y => y, :status => st
	end

	def full_info
		self.to_hash.merge(:buildings => buildings.to_a, :dinosaurs => dinosaurs.to_a)
	end

	# TODO: 刷新资源
	def update_resource(time = Time.now.to_i)
		
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

	def refresh_resource_output(time = Time.now.to_i)
		tech_lumbering = find_tech_by_type(Technology.hashes[:lumbering])
		tech_mining = find_tech_by_type(Technology.hashes[:mining])
		self.basic_wood_inc = tech_lumbering.property[:wood_inc]
		self.basic_stone_inc = tech_mining.property[:stone_inc]

		buffs_inc = buffs.sum do |buff|
			buff.res_inc
		end

		self.wood_inc = (self.basic_wood_inc * (1 + buffs_inc)).to_i
		self.stone_inc = (self.basic_stone_inc * (1 + buffs_inc)).to_i
		self
	end

	def calc_resources_increase(time = Time.now.to_i)
		delta_t = time - update_resource_at
		if delta_t < 10
			return
		else
			delta_t = delta_t / 3600.0 # seconds to hours
		end

		wood_delta = (self.wood_inc * (1 + delta_t)).to_i
		stone_delta = (self.stone_inc * (1 + delta_t)).to_i

		if (self.wood + wood_delta) > self.wood_max
			wood_delta = 0
		end

		if (self.stone + stone_delta) > self.stone_max
			stone_delta = 0
		end

		self.wood += wood_delta
		self.stone += stone_delta
		
		self.update_resource_at = time
		self
	end

	def refresh_resource(time = Time.now.to_i)
		refresh_resource_output(time)
		calc_resources_increase(time)
		self
	end

	def refresh_resource!(time = Time.now.to_i)
		
		refresh_resource(time)
		
		write_back_resources!
	end

	def write_back_resources!
		if self.sets 	:basic_wood_inc 		=> basic_wood_inc,
									:wood_inc 					=> wood_inc,
									:basic_stone_inc 		=> basic_stone_inc,
									:stone_inc 					=> stone_inc,
									:update_resource_at => update_resource_at,
									:wood 							=> wood,
									:stone 							=> stone
			return self
		else
			false
		end
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
		self.update_resource_at = ::Time.now.utc.to_i
	end

	def after_create
		creeps = Creeps.create :x => x + 2, :y => y + 2, :is_quest_monster => true, :type => 1, :player_id => player_id
		country.add_quest_monster(creeps.index)

		self.mutex do
			if buildings.find(:type => Building.hashes[:residential]).blank?
				create_building(Building.hashes[:residential], 1, 25, 25, Building::STATUS[:finished])
			end
		end
	end

	def after_delete
		self.buildings.map(&:delete)
	end
end
