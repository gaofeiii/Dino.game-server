class AdviseRelation < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :adviser_id
	reference :player, 	Player

	def adviser
		Player[adviser_id]
	end
end
