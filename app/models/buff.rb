class Buff < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	TYPES = { 
		:inc_resource => 1,
		:inc_research => 2,
		:inc_attack => 3,
		:inc_defense => 4,
	}

	SOURCES = {
		:scroll 	=> 1,
		:advisor 	=> 2,
		:god  		=> 3
	}

	attribute :buff_type, 		Type::Integer
	attribute :buff_level, 		Type::Integer
	attribute :buff_value, 		Type::Float
	attribute :buff_source, 	Type::Integer

	reference :player, 		Player
	reference :village, 	Village

	index :buff_type

	def to_hash
		{
			:buff_type => buff_type,
			:buff_level => buff_level,
			:buff_value => buff_value,
			:buff_source => buff_source
		}
	end

	def res_inc
		if buff_type == TYPES[:research_inc]
			buff_value
		else
			0
		end
	end
end
