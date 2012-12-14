class GoldMine < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	attribute :x, 	Type::Integer
	attribute :y, 	Type::Integer
	attribute :index, Type::Integer

	attribute :type, 	Type::Integer
	attribute :level,	Type::Integer

	attribute :strategy_id

	collection :monsters, 	Monster

	reference :player, 	Player

	index :x
	index :y
	index :level

	def defense_troops
		owner = self.player
		if owner.nil?

			if monsters.blank?
				# 创建两只属于此金矿的monster
				3.times do |i|
					case level
					when 1
						m_type = Random.rand(1..2)
					when 2
						m_type = Random.rand(2..3)
					when 3
						m_type = Random.rand(3..5)
					end

					Monster.create_by(:type => m_type, :status => Monster::STATUS[:adult], :gold_mine_id => id)
				end
			end
			
			monsters.to_a
		elsif owner.is_a?(Player)
			# TODO:
			[]
		end
	end

	def to_hash
		hash = {
			:x => x,
			:y => y,
			:type => type,
			:level => level
		}
		hash[:strategy] = Strategy[strategy_id].try(:to_hash)
	end

	protected

	def before_save
		self.index = x * Country::COORD_TRANS_FACTOR + y
	end

end
