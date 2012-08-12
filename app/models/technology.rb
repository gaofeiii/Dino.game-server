class Technology < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	attribute :level, 			Type::Integer
	attribute :type,				Type::Integer
	attribute :status, 			Type::Integer
	attribute :start_time, 	Type::Integer
	attribute :finish_time, Type::Integer

	index :type

	reference :player, :Player

	def self.info
		TECHNOLOGIES
	end

	def info(lv = self.level)
		TECHNOLOGIES.type(self.type).level(lv)
	end

	def next_level
		info(self.level + 1)
	end

	def research!
		self.status = 1
		self.start_time = ::Time.now.to_i
		self.finish_time = ::Time.now.to_i + next_level.cost[:time]
		self.save
	end

	def to_hash
		hash = {
			:level => level,
			:type => type,
			:status => status
		}
		if status == 1
			hash[:start_time] = start_time
			hash[:finish_time] = finish_time
		end
		hash
	end

	def research_finished?
		if status == 1
			return false if ::Time.now.to_i < finish_time
		end
		return true
	end

	def update_status!
		if status == 1
			if ::Time.now.to_i >= finish_time
				self.status = 0
				self.level = level + 1
				self.start_time = 0
				self.finish_time = 0
				self.save
			end
		end
		self
	end

	protected

	def before_create
		self.status = 0
		self.start_time = 0
		self.finish_time = 0
	end
end
