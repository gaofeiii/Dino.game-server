# class Monster < Ohm::Model
# 	include Ohm::DataTypes
# 	include Ohm::Timestamps
# 	include Ohm::Callbacks
# 	include OhmExtension

# 	attribute :type, 		Type::Integer
# 	attribute :level,		Type::Integer
# 	attribute :hp, 			Type::Integer
# 	attribute :attack, 	Type::Integer
# 	attribute :defense,	Type::Integer
# 	attribute :agility,	Type::Integer

# 	reference :gold_mine, GoldMine
# end

class Monster < Dinosaur
	reference :gold_mine, 	GoldMine
end