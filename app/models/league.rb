class League < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	include LeagueConst
	include LeagueWarHelper
	include LeagueRankHelper

	attribute :name
	attribute :desc
	attribute :level, 	Type::Integer
	attribute :president_id
	attribute :contribution, 	Type::Integer
	attribute :xp,			Type::Integer

	attribute :total_battle_power, 	Type::Integer

	attribute :wood,		Type::Integer
	attribute :stone, 	Type::Integer

	collection :members, Player
	collection :league_member_ships, LeagueMemberShip
	collection :league_applys, LeagueApply
	set :winned_mines, GoldMine

	collection :gold_mines, GoldMine

	attribute :most_gold, 	Type::Integer

	index :name

	DONATE_TYPE = {
		:wood => 1,
		:stone => 2
	}

	DONATE_FACTOR = 192

	def receive_res(wood:0, stone:0)
		db.multi do |t|
			t.hincrby(key, :wood, wood) if wood > 0
			t.hincrby(key, :stone, stone) if stone > 0
		end
		gets(:wood, :stone)
	end

	def spend_res(wood:0, stone:0)
		return false if wood < 0 || stone < 0 || wood > self.wood || stone > self.stone

		db.multi do |t|
			t.hincrby(key, :wood, -wood) if wood > 0
			t.hincrby(key, :stone, -stone) if stone > 0
		end
		gets(:wood, :stone)
	end

	def update_level!
		if xp >= next_level_xp
			self.xp -= next_level_xp
			self.level += 1
			self.sets(:xp => xp, :level => level)
		end
	end

	def president
		Player[president_id]
	end

	def to_hash
		hash = {
			:id => id.to_i,
			:name => name,
			:desc => desc,
			:level => level,
			:president => president.try(:nickname).to_s,
			:contribution => contribution,
			:member_count => league_member_ships.size,
			:xp => xp,
			:max_xp => next_level_xp,
			:rank => my_league_rank,
			:wood => wood,
			:stone => stone,
			:gold_mine_count => gold_mines.size,
			:can_get_league_gold => harvest_gold.to_i
		}
	end

	def members_list
		league_member_ships.map do |member|
			member.to_hash
		end
	end

	def next_level_xp
		self.info[:next_level_xp]
	end

	def apply_list
		league_applys.map do |apply|
			apply.to_hash
		end
	end

	def add_new_member(member)
		membership = LeagueMemberShip.create 	:player_id => member.id,
																					:league_id => self.id,
																					:level => League.positions[:member]
		if membership
			member.update :league_id => id, :league_member_ship_id => membership.id
		end
	end

	def harvest_gold
		# (winned_mines.sum{|gold_mine| gold_mine.output}).to_i
		most_gold
	end

	def calc_harvest_gold
		curr = winned_mines.ids[0, 5].sum{|g_id| GoldMine[g_id].try(:output).to_i * 24}.to_i
		self.most_gold = curr if curr.to_i > most_gold
	end

	def calc_harvest_gold!
		calc_harvest_gold
		self.set :most_gold, most_gold
	end

	def dismiss!
		league_member_ships.map(&:delete)
		league_applys.map(&:delete)
		self.delete
	end

	protected
	def before_create
		self.level = 1 if level.zero?
	end
end
