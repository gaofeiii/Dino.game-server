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

	attribute :start_time, 	Type::Integer
	attribute :finish_time, Type::Integer
	attribute :under_attack, Type::Boolean

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

	def owner_name
		if player_id
			db.hget(Player.key[player_id], :nickname)
		else
			"Monster"
		end
	end

	def to_hash
		hash = {
			:x => x,
			:y => y,
			:type => type,
			:level => level,
			:gold_output => GoldMine.gold_output(level),
			:owner => owner_name
		}
		stra = Strategy[strategy_id]
		hash[:strategy] = stra.to_hash if stra

		left_time = if player_id
			t = finish_time - Time.now.to_i
			t = t < 0 ? -1 : t
		else
			-1
		end

		hash[:left_time] = left_time

		return hash
	end

	def self.gold_output(lvl = 0)
		case lvl
		when 1
			100
		when 2
			400
		when 3
			800
		else
			0
		end
	end

	def output
		self.class.gold_output(level)
	end

	protected

	def before_save
		self.index = x * Country::COORD_TRANS_FACTOR + y
	end

end
