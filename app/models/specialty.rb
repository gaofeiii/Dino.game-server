class Specialty < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps

	include OhmExtension

	attribute :type, 		Type::Integer
	attribute :count,	 	Type::Integer

	reference :player, 	:Player
end