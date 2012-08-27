class Building < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps
	include OhmExtension

	attribute :type, Type::Integer
	attribute :level, Type::Integer
	attribute :x, Type::Integer
	attribute :y, Type::Integer

	attribute :status, Type::Integer
	attribute :start_building_time, 	Type::Integer
	attribute :time, Type::Integer

	index :type
	index :village_id

	reference :village, Village

	# Class methods:

	class << self
		def info
			BUILDINGS
		end

		def names
			BUILDING_NAMES
		end

		def types
			BUILDING_TYPES
		end

		def cost(type)
			BUILDINGS[type][:cost]
		end
	end

	# Instance methods:

	def info
		self.class.info.type(self.type)
	end

	def update_status!
		left_time = (::Time.now.utc.to_i - start_building_time)
		case status
		when 0
			if left_time > self.info.cost[:time]
				self.status = 2
				self.time = 0
			elsif left_time > 0 && left_time >= self.info.cost[:time]/2
				self.status = 1
				self.time = left_time - self.info.cost[:time]/2
			end
		when 1
			if left_time > self.info.cost[:time]
				self.status = 2				
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
			:x => x,
			:y => y
		}
	end

	protected

	def before_create
		self.status = 0
		self.start_building_time = Time.now.utc.to_i
	end
end

