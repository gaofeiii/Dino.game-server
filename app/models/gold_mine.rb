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

	attribute :occupy_time,	Type::Integer
	attribute :update_gold_time, 	Type::Integer

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

	def defense_troops(index = nil)
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
			sta = Strategy[strategy_id]
			if sta
				sta.dinosaurs.map do |dino_id|
					Dinosaur[dino_id]
				end.compact
			else
				[]
			end
		end
	end

	def owner_name
		if player_id
			db.hget(Player.key[player_id], :nickname)
		else
			I18n.t('monster_name.general')
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

		if type == TYPE[:league] && !winner_league_id.blank?
			hash[:owner_name] = db.hget(League.key[winner_league_id], :name)
		end

		stra = strategy
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

	# per hour
	def output
		self.class.gold_output(level)
	end

	def strategy
		Strategy[strategy_id]
	end

	def refresh_gold!(t = Time.now.to_i)
		@player = self.player
		if @player
			delta_t = (t - self.update_gold_time) / 3600.0
			harvest_gold_count = (delta_t * output).to_i

			if harvest_gold_count > 0
				@player.receive!(:gold => harvest_gold_count)
				Mail.create_goldmine_total_harvest_mail :receiver_id 		=> @player.id,
																								:receiver_name 	=> @player.nickname,
																								:locale 				=> @player.locale,
																								:x 							=> x,
																								:y 							=> y,
																								:count 					=> harvest_gold_count
				self.set :update_gold_time, t
			end
			
		end
	end

	# 将goldmine列入刷新队列
	def move_to_refresh_queue(refresh_time)
		# Background.add_queue(self.class, id, 'refresh_gold!', refresh_time)
	end

	def self.refresh_all_players_goldmine
		Player.none_npc.each do |player|
			player.harvest_gold_mines
		end
	end


	protected

	def before_create
		self.type = TYPE[:normal] if type.zero?
	end

	def before_save
		self.index = x * Country::COORD_TRANS_FACTOR + y
	end

end
