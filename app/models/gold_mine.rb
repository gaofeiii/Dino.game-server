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

	include GoldMineConst
	include GoldMineLeagueHelper

	TYPE = {
		:normal => 1,
		:league => 2
	}

	def defense_troops
		if player_id.blank?

			if monsters.blank?
				# 创建属于此金矿的monster
				m_level, m_count = Monster.get_monster_level_and_number_by_type(self.level)
				m_type = rand(1..5)
				m_count.times do |i|
					Monster.create_by :level => m_level, :type => m_type, :gold_mine_id => id
				end
			end
			monsters.to_a
		else
			# TODO: player's defense troops
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
