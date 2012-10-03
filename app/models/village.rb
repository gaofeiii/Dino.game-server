class Village < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps
	include OhmExtension

	attribute :name
	attribute :x, 									Type::Integer
	attribute :y, 									Type::Integer

	attribute :wood,								Type::Integer
	attribute :wood_inc, 						Type::Integer
	attribute :wood_max, 						Type::Integer
	attribute :stone, 							Type::Integer
	attribute :stone_inc,						Type::Integer
	attribute :stone_max,						Type::Integer
	attribute :population, 					Type::Integer
	attribute :population_inc,			Type::Integer
	attribute :population_max,			Type::Integer
	attribute :update_resource_at, 	Type::Integer
		

	attribute :player_id, 					Type::Integer
	attribute :country_id, 					Type::Integer

	collection :buildings, 					Building
	collection :dinosaurs, 					Dinosaur
	collection :buffs, 							Buff


	index :name
	index :x
	index :y
	index :country_id

	# 获取村庄所属的玩家
	def player
		Player[player_id]
	end

	def to_hash(*args)
		hash = {
			:id => id.to_s,
			:name => name,
			:x => x,
			:y => y,
			:resources => resources,
			:country_id => country_id
		}

		options = if args.include?(:all)
			args + [:buildings]
		else
			args
		end

		options.each do |arg|
			case arg
			when :buildings
				hash[:buildings] = buildings.to_a.map(&:update_status!).map(&:to_hash)
			end
		end

		hash
	end

	def resources
		{
			:wood => wood,
			:wood_inc => wood_inc,
			:wood_max => wood_max,
			:stone => stone, 		
			:stone_inc => stone_inc,	
			:stone_max => stone_max,
			:population => population, 		
			:population_inc => population_inc,
			:population_max => population_max,
		}
	end

	[:spend, :receive].each do |name|
		define_method("#{name}!") do |args = {}|
			db.multi do |t|
				args.each do |att, val|
					if self.respond_to?(att)
						return false if send(att) < val
						v = name == :spend ? -val : val
						t.hincrby(self.key, att, v)
					end
				end
			end
			load!
		end
	end

	# 设置村庄所属的玩家
	# 不会写到数据库中，如果要保存到数据库中，需要调用save方法
	def player=(plyr)
		self.player_id = plyr ? plyr.id : nil
		self
	end

	def create_building(building_type, level = 1, x, y)
		Building.create :type => building_type.to_i, :level => level, :village_id => id, :x => x, :y => y
	end

	def full_info
		self.to_hash.merge(:buildings => buildings.to_a, :dinosaurs => dinosaurs.to_a)
	end

	protected
	def before_create
		self.wood = 99999
		self.stone = 99999
		self.population = 99999
		self.update_resource_at ||= ::Time.now.utc.to_i
	end
end
