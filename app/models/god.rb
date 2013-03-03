class God < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	include GodConst

	attribute :type, 					Type::Integer
	attribute :level,					Type::Integer
	attribute :start_time, 		Type::Integer
	attribute :end_time,			Type::Integer

	index :type

	reference :player, Player

	def to_hash
		{
			:type => type,
			:level => level,
			:start_time => start_time,
			:curr_time => ::Time.now.to_i,
			:end_time => end_time
		}
	end

	def expired?
		::Time.now.to_i >= end_time
	end

end
