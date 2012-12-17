class Building < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps
	include OhmExtension

	include BuildingConst

	STATUS = {:new => 0, :half => 1, :finished => 2}

	attribute :type, Type::Integer
	attribute :level, Type::Integer
	attribute :x, Type::Integer
	attribute :y, Type::Integer

	attribute :status, Type::Integer
	attribute :start_building_time, 	Type::Integer
	attribute :time, Type::Integer

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

	def to_hash
		{
			:id => id.to_i,
			:type => type,
			:level => level,
			:status => status,
			:time => time,
			:time_pass => Time.now.to_i - start_building_time,
			:x => x,
			:y => y
		}
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

	protected

	def before_create
		self.start_building_time = Time.now.utc.to_i
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

