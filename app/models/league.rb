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

	collection :members, Player
	collection :league_member_ships, LeagueMemberShip
	collection :league_applys, LeagueApply
	set :winned_mines, GoldMine

	index :name

	DONATE_TYPE = {
		:wood => 1,
		:stone => 2
	}

	DONATE_FACTOR = 10

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
			:gold_mine_count => winned_mines.size,
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
		membership = LeagueMemberShip.create :player_id => member.id,
																					:league_id => self.id,
																					:level => League.positions[:member]
		if membership
			member.update :league_id => id, :league_member_ship_id => membership.id
		end
	end

	def harvest_gold
		(winned_mines.sum{|gold_mine| gold_mine.output * 8} * 0.8).to_i
	end

	def dismiss!
		league_member_ships.map(&:delete)
		league_applys.map(&:delete)
		self.delete
	end

	# def self.battle_rank(count = 20)
	# 	result = []

	# 	League.all.sort_by(:total_battle_power, :order => "DESC", :limit => [0, count]).each_with_index do |league, idx|
	# 		result << {
	# 			:rank => idx + 1,
	# 			:id => league.id,
	# 			:name => league.name,
	# 			:total_battle_power => league.total_battle_power,
	# 			:level => league.level,
	# 			:member_count => league.league_member_ships.size
	# 		}
	# 	end

	# 	return result
	# end

	# def self.refresh_league_battle_power
	# 	self.all.each do |league|
	# 		record = league.members.ids.sum do |member_id|
	# 			db.hget("Player:#{member_id}", :battle_power).to_i
	# 		end
	# 		league.update :total_battle_power => record if league.total_battle_power != record
	# 	end
	# end

	protected
	def before_create
		self.level = 1 if level.zero?
	end
end
