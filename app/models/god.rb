class God < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	TYPE = {
		:coeus => 1,
		:mercury => 2,
		:mars => 3,
		:ceres => 4
	}

	attribute :type, 					Type::Integer
	attribute :level,					Type::Integer
	attribute :start_time, 		Type::Integer

	index :type

	reference :player, Player

	def to_hash
		{
			:type => type,
			:level => level,
			:start_time => start_time
		}
	end

	protected

	def before_save
		self.start_time ||= ::Time.now.to_i		
	end
end
