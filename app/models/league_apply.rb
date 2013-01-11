class LeagueApply < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	reference :league, League
	reference :player, Player

	def player_nickname
		db.hget(Player.key[player_id], :nickname)
	end

	def to_hash
		{
			:id => id.to_i,
			:nickname => player_nickname,
			:level => 1,
			:player_id => player_id
		}
	end
end
