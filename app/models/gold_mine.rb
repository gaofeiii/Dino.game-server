class GoldMine < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	attribute :x, 	Type::Integer
	attribute :y, 	Type::Integer

	attribute :type, 	Type::Integer
	attribute :level,	Type::Integer

	collection :monsters, 	Monster

	reference :player, 	Player

	def defense_troops
		owner = self.player
		if owner.nil?
			# 创建两只属于此金矿的monster
			2.times do |i|
				case level
				when 1
					monster_type = Random.rand(1..5)
				when 2
					monster_type = Random.rand(6..10)
				when 3
					monster_type = Random.rand(11.15)
				end
			end
		end
	end

end
