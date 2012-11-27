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
	attribute :country_index,				Type::Integer

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

	def create_building(building_type, level = 1, x, y, st)
		Building.create :type => building_type.to_i, :level => level, :village_id => id, :x => x, :y => y, :status => st
	end

	def full_info
		self.to_hash.merge(:buildings => buildings.to_a, :dinosaurs => dinosaurs.to_a)
	end

	# TODO: 刷新资源
	def update_resource
		
	end

	protected

	def before_save
		if index.zero?
			self.index = x * Country::COORD_TRANS_FACTOR + y
		end
	end

	def before_create
		self.wood = 99999
		self.stone = 99999
		self.population = 99999
		self.update_resource_at ||= ::Time.now.utc.to_i
	end

	def after_create
		self.mutex do
			$test_count ||= 0
			$test_count += 1
			puts "*** ---Building residential: #{$test_count} times--- ***"
			if buildings.find(:type => Building.hashes[:residential]).blank?
				create_building(Building.hashes[:residential], 1, 25, 25, Building::STATUS[:finished])
			end
		end
	end

	def after_delete
		self.buildings.map(&:delete)
	end
end
