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

	def advisor
		Player[advisor_id]
	end

	def advisor_level
		@level ||= db.hget(Player.key[advisor_id], :level).to_i
		@level
	end
end
