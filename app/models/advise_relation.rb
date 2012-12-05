class AdviseRelation < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :type, 				Type::Integer
	attribute :start_time, 	Type::Integer
	attribute :days,				Type::Integer

	attribute :advisor_id
	attribute :employer_id

	index :advisor_id
	index :employer_id
	index :type

	def advisor_level
		@level ||= db.hget(Player.key[advisor_id], :level).to_i
		@level
	end

	def finish_time
		start_time + days.days.to_i
	end

	def to_hash
		advisor = Player.new :id => advisor_id
		advisor.gets(:level)
		left_time = start_time + days.days.to_i - ::Time.now.to_i
		left_time = left_time < 0 ? 0 : left_time
		{
			:advisor_id => advisor_id,
			:advisor_level => level,
			:advisor_type => type,
			:left_time => start_time + days.days.to_i - ::Time.now.to_i
		}
	end
end
