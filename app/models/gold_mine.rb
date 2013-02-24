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
	index :type

	include GoldMineLeagueHelper

	TYPE = {
		:normal => 1,
		:league => 2
	}

	def defense_troops
		if player_id.blank?

			if monsters.blank?
				# 创建属于此金矿的monster
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
		else
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
			:id => id,
			:x => x,
			:y => y,
			:type => type,
			:level => level,
			:gold_output => GoldMine.gold_output(level),
			:owner => owner_name,
			:owner_id => player_id.to_i,
			:goldmine_type => goldmine_type
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

	def goldmine_type
		case type
		when TYPE[:normal]
			return level / 10 + 1
		when TYPE[:league]
			return 3
		end
	end

	def self.gold_output(lvl = 0)
		# case lvl
		# when 1
		# 	100
		# when 2
		# 	400
		# when 3
		# 	800
		# else
		# 	0
		# end
		100 + (lvl - 1) * 50
	end

	def output
		self.class.gold_output(level)
	end

	def strategy
		Strategy[strategy_id]
	end


	protected

	def before_create
		self.type = TYPE[:normal] if type.zero?
	end

	def before_save
		self.index = x * Country::COORD_TRANS_FACTOR + y
	end

end
