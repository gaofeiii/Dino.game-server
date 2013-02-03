class League < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	include LeagueConst
	include LeagueWarHelper

	attribute :name
	attribute :desc
	attribute :level, 	Type::Integer
	attribute :president_id
	attribute :contribution, 	Type::Integer
	attribute :xp,			Type::Integer

	collection :members, Player
	collection :league_member_ships, LeagueMemberShip
	collection :league_applys, LeagueApply

	index :name

	DONATE_TYPE = {
		:wood => 1,
		:stone => 2
	}

	DONATE_FACTOR = 10

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
			:rank => rand(1..100),
			:gold_mine_count => rand(1..5),
			:can_get_league_gold => harvest_gold
		}
	end

	def members_list
		league_member_ships.map do |member|
			member.to_hash
		end
	end

	def apply_list
		league_applys.map do |apply|
			apply.to_hash
		end
	end

	def add_new_member(member)
		membership = LeagueMemberShip.create :player_id => member.id,
																					:league_id => self.id,
																					:level => League.levels[:member]
		if membership
			member.update :league_id => id, :league_member_ship_id => membership.id
		end
	end

	def harvest_gold
		1000
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
