class Buff < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	TYPE = { 
		:wood_inc 			=> 1, 
		:stone_inc 			=> 2, 
		:gold_inc 			=> 3, 
		:resource_inc 	=> 4, 
		:exp_inc 				=> 5 
	}

	attribute :buff_type, 		Type::Integer

	reference :player, 		Player
	reference :village, 	Village
end
