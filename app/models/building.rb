class Building < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps
	include OhmExtension

	include BuildingConst

	STATUS = {:new => 0, :half => 1, :finished => 2}
	HARVEST_AVAILABLE_TIME = 30.seconds
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

	index :type
	index :status
	index :village_id

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

	def to_hash(*args)
		if is_resource_building?
			update_harvest
		end
		hash = {
			:id => id.to_i,
			:type => type,
			:level => level,
			:status => status,
			:time => time,
			:time_pass => Time.now.to_i - start_building_time,
			:x => x,
			:y => y
		}
		if args.include?(:harvest_info) && is_resource_building?
			hash[:harvest_info] = harvest_info
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
		now_time = ::Time.now.to_i
		case type
		when Building.hashes[:collecting_farm]
			produce_rate = HARVEST_AVAILABLE_TIME # TODO
			delta_t = now_time - harvest_updated_time
			count_inc = delta_t / produce_rate # 5.minutes
			if count_inc > 0
				self.harvest_updated_time = now_time - delta_t % produce_rate #5.minutes
				self.harvest_count += count_inc
			end
			self
		when Building.hashes[:hunting_field]
			produce_rate = HARVEST_AVAILABLE_TIME # TODO
			delta_t = now_time - harvest_updated_time
			count_inc = delta_t / produce_rate # 5.minutes
			if count_inc > 0
				self.harvest_updated_time = now_time - delta_t % produce_rate #5.minutes
				self.harvest_count += count_inc
			end
			self
		when Building.hashes[:lumber_mill]
			produce_rate = 0.5 # TODO
			delta_t = now_time - harvest_updated_time
			count_inc = delta_t / produce_rate # 5.minutes
			if count_inc > 0
				self.harvest_updated_time = now_time - delta_t % produce_rate #5.minutes
				self.harvest_count += count_inc.to_i
			end
			self
		when Building.hashes[:quarry]
			produce_rate = 0.5 # TODO
			delta_t = now_time - harvest_updated_time
			count_inc = delta_t / produce_rate # 5.minutes
			if count_inc > 0
				self.harvest_updated_time = now_time - delta_t % produce_rate #5.minutes
				self.harvest_count += count_inc.to_i
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

	def after_save
		case type
		when Building.hashes[:warehouse]
			self.village.update_warehouse!
		end
	end

	def before_save
		if level > 0
			case type
			when Building.hashes[:lumber_mill]
				self.village.set :wood_inc, 100 if technology_ids.empty?
			end
		end
	end
end

