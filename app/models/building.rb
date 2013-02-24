class Building < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps
	include OhmExtension

	include BuildingConst

	STATUS = {:new => 0, :half => 1, :finished => 2}
	HARVEST_AVAILABLE_TIME = 2.minutes
	HARVEST_CHANGE_TIME = 2.minute

	attribute :type, Type::Integer
	attribute :level, Type::Integer
	attribute :x, Type::Integer
	attribute :y, Type::Integer

	attribute :status, Type::Integer
	attribute :start_building_time, 	Type::Integer
	attribute :time, Type::Integer

	# Farm attributes:
	attribute :harvest_start_time, 		Type::Integer
	attribute :harvest_updated_time,	Type::Integer
	attribute :harvest_receive_time, 			Type::Integer
	attribute :harvest_type,					Type::Integer	# Specialty(Item category: 2)
	attribute :resource_type,					Type::Integer
	attribute :harvest_count,					Type::Integer

	attribute :has_worker, 						Type::Integer

	index :type
	index :status
	index :village_id
	index :has_worker
	index :resource_building

	def resource_building
		is_resource_building?
	end

	reference :village, Village

	# Instance methods:

	def update_status!
		left_time = (::Time.now.utc.to_i - start_building_time)
		case status
		when STATUS[:new]
			if left_time > self.info[:cost][:time]
				self.status = STATUS[:finished]
				self.time = 0
			elsif left_time > 0 && left_time >= 10 # self.info[:cost][:time]/2
				self.status = STATUS[:half]
				self.time = left_time - self.info[:cost][:time]/2
			end
		when 1
			if left_time > self.info[:cost][:time]
				self.status = STATUS[:finished]
			end
		end
		self.save
	end

	def build_speed_up_gem_cost
		l_time = info[:cost][:time] - (::Time.now.to_i - start_building_time)
		l_time = 0 if l_time < 0
		(l_time / 300.0).ceil
	end

	def to_hash(*args)
		if is_resource_building?
			update_harvest
		end
		hash = {
			:id => id.to_i,
			:type => type,
			:level => level,
			:status => status,
			:time_pass => Time.now.to_i - start_building_time,
			:x => x,
			:y => y,
			:time => time,
			:worker_number => has_worker
		}

		# 建筑的属性
		player = Player.new :id => player_id
		case type
		when Building.hashes[:residential]
			hash.merge!(:worker_supply => player.tech_worker_number)
		when Building.hashes[:lumber_mill]
			wood_rate = player.tech_produce_wood_rate
			hash[:basic_wood_inc] = wood_rate
		when Building.hashes[:quarry]
			stone_rate = player.tech_produce_stone_rate
			hash[:basic_stone_inc] = stone_rate
		when Building.hashes[:hunting_field]
			meat_rate = player.tech_produce_meat_rate
			hash[:basic_meat_inc] = meat_rate
		when Building.hashes[:collecting_farm]
			fruit_rate = player.tech_produce_fruit_rate
			hash[:basic_food_inc] = fruit_rate
		when Building.hashes[:habitat]

		when Building.hashes[:beastiary]
			
		when Building.hashes[:market]
				
		when Building.hashes[:workshop]
			
		when Building.hashes[:temple]
			
		when Building.hashes[:warehouse]
			hash[:resource_max] = player.tech_warehouse_size
		end

		if hash[:time].to_i < HARVEST_AVAILABLE_TIME
			hash[:time] = HARVEST_AVAILABLE_TIME
		end

		if args.include?(:harvest_info) && is_resource_building?
			hash[:harvest_info] = harvest_info
		end

		if args.include?(:steal_info) && is_resource_building?
			hash[:harvest_info] = steal_info
		end
		hash
	end

	def harvest_info
		pass_time = ::Time.now.to_i - harvest_updated_time
		pass_time = pass_time > HARVEST_AVAILABLE_TIME ? HARVEST_AVAILABLE_TIME : pass_time
		hash = {
			:time_pass => pass_time,
			:total_time => HARVEST_AVAILABLE_TIME,
			:count => harvest_count
		}
		if is_collecting_farm? || is_hunting_field?
			hash[:food_type] = harvest_type
		end

		if is_lumber_mill? || is_quarry?
			hash[:res_type] = harvest_type
		end
		hash
	end

	def steal_info
		pass_time = ::Time.now.to_i - harvest_updated_time
		pass_time = pass_time > HARVEST_AVAILABLE_TIME ? HARVEST_AVAILABLE_TIME : pass_time
		hash = {
			:time_pass => pass_time,
			:total_time => HARVEST_AVAILABLE_TIME,
			:count => harvest_count / 10
		}
		if is_collecting_farm? || is_hunting_field?
			hash[:food_type] = harvest_type
		end

		if is_lumber_mill? || is_quarry?
			hash[:res_type] = harvest_type
		end
		hash
	end

	def player_id
		if @player_id.nil?
			@player_id = db.hget(Village.key[village_id], :player_id).to_i
		end
		return @player_id
	end

	def technology_ids
		db.smembers("Technology:indices:player_id:#{player_id}")
	end

	def update_harvest
		return false if status < STATUS[:finished]
		now_time = ::Time.now.to_i

		player = Player.new :id => player_id
		warehouse_size = player.tech_warehouse_size

		case type
		when Building.hashes[:collecting_farm]
			produce_rate = 3600 / (player.tech_produce_fruit_rate * (1 + player.adv_inc_resource))
			delta_t = now_time - harvest_updated_time
			count_inc = delta_t / produce_rate
			if count_inc > 0
				self.harvest_updated_time = now_time - delta_t % produce_rate
				self.harvest_count += count_inc
			end
			self
		when Building.hashes[:hunting_field]
			produce_rate = 3600 / (player.tech_produce_meat_rate * (1 + player.adv_inc_resource)) # seconds/1 meat
			delta_t = now_time - harvest_updated_time
			count_inc = delta_t / produce_rate
			if count_inc > 0
				self.harvest_updated_time = now_time - delta_t % produce_rate
				self.harvest_count += count_inc
			end
			self
		when Building.hashes[:lumber_mill]
			player.get(:wood)

			if player.wood >= warehouse_size
				self.harvest_count = 0
				return
			end

			produce_rate = 3600 / (player.tech_produce_wood_rate * (1 + player.adv_inc_resource)) # seconds/1 wood
			delta_t = now_time - harvest_updated_time
			count_inc = delta_t / produce_rate
			if count_inc > 0
				self.harvest_updated_time = now_time - delta_t % produce_rate
				self.harvest_count += count_inc.to_i

				if player.wood + self.harvest_count > warehouse_size
					self.harvest_count = warehouse_size - player.wood
					self.harvest_count = 0 if self.harvest_count < 0
				end
			end
			self
		when Building.hashes[:quarry]
			player.get(:stone)

			if player.stone >= warehouse_size
				self.harvest_count = 0
				return
			end
			
			produce_rate = 3600 / (player.tech_produce_stone_rate * (1 + player.adv_inc_resource)) # seconds/1 stone
			delta_t = now_time - harvest_updated_time
			count_inc = delta_t / produce_rate
			if count_inc > 0
				self.harvest_updated_time = now_time - delta_t % produce_rate
				self.harvest_count += count_inc.to_i

				if player.stone + self.harvest_count > warehouse_size
					self.harvest_count = warehouse_size - player.stone
					self.harvest_count = 0 if self.harvest_count < 0
				end				
			end
			self
		else
			return false
		end
	end

	def update_harvest!
		if update_harvest
			self.sets :harvest_updated_time => harvest_updated_time,
								:harvest_count => harvest_count
		end
	end

	self.names.each do |name|
		define_method("is_#{name}?") do
			self.type == self.class.hashes[name]
		end
	end

	def is_resource_building?
		self.class.resource_building_types.include?(type)
	end

	protected

	def before_create
		now_time = ::Time.now.to_i
		self.start_building_time = now_time

		if self.is_resource_building?
			self.harvest_start_time = now_time
			self.harvest_updated_time = now_time
			self.harvest_receive_time = now_time

			case type
			when Building.hashes[:collecting_farm]
				self.harvest_type = rand(1..4)
			when Building.hashes[:hunting_field]
				self.harvest_type = rand(5..8)
			when Building.hashes[:lumber_mill]
				self.harvest_type = Resource::WOOD
			when Building.hashes[:quarry]
				self.harvest_type = Resource::STONE
			end
		end
	end

end

