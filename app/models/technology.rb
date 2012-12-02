class Technology < Ohm::Model
	STATUS = {:idle => 0, :researching => 1}

	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	include TechnologiesConst

	attribute :level, 			Type::Integer
	attribute :type,				Type::Integer
	attribute :status, 			Type::Integer
	attribute :start_time, 	Type::Integer
	attribute :finish_time, Type::Integer

	index :type
	index :status

	reference :player, :Player

	def research!
		self.status = STATUS[:researching]
		self.start_time = ::Time.now.to_i
		self.finish_time = ::Time.now.to_i + next_level.cost[:time]
		self.save
	end

	def to_hash
		hash = {
			:id => id.to_i,
			:level => level,
			:type => type,
			:status => status
		}
		if status == STATUS[:researching]
			hash[:start_time] = start_time
			hash[:finish_time] = finish_time
		end
		hash
	end

	def research_finished?
		if status == STATUS[:researching]
			return false if ::Time.now.to_i < finish_time
		end
		return true
	end

	def update_status!
		if status == STATUS[:researching]
			if ::Time.now.to_i >= finish_time
				self.status = STATUS[:idle]
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
