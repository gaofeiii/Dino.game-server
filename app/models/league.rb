class League < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	attribute :name
	attribute :desc
	attribute :president_id


	collection :members, Player
	collection :league_member_ships, LeagueMemberShip
	collection :league_applys, LeagueApply

	index :name

	def president
		Player[president_id]
	end

	def to_hash
		hash = {
			:id => id.to_i,
			:name => name,
			:desc => desc,
			:president => president.try(:nickname).to_s,
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

	def dismiss!
		league_member_ships.map(&:delete)
		league_applys.map(&:delete)
		self.delete
	end

	protected
	def before_create
		self.level = 1
	end
end
