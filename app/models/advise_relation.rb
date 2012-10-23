class AdviseRelation < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :advisor_id
	attribute :type, 		Type::Integer
	reference :player, 	Player

	def advisor
		Player[advisor_id]
	end
end
