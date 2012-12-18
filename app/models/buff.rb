class Buff < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	TYPES = { 
		:resource_inc => 1,
		:exp_inc 			=> 2,
		:attack_inc		=> 3,
		:defense_inc 	=> 4,
		:agility_inc 	=> 5,
		:research_inc => 6
		# :wood_inc 			=> 1, 
		# :stone_inc 			=> 2, 
		# :gold_inc 			=> 3, 
		# :resource_inc 	=> 4, 
		# :exp_inc 				=> 5,
		# :attack_inc 		=> 6,
		# :defense_inc		=> 7,
		# :agility_inc		=> 8,
		# :research_inc 	=> 9
	}

	SOURCES = {
		:scroll 	=> 1,
		:advisro 	=> 2,
		:god  		=> 3
	}

	attribute :buff_type, 		Type::Integer
	attribute :buff_level, 		Type::Integer
	attribute :buff_value, 		Type::Float
	attribute :buff_source

	reference :player, 		Player
	reference :village, 	Village

	index :buff_type

	def res_inc
		if buff_type == TYPES[:research_inc]
			buff_value
		else
			0
		end
	end
end
