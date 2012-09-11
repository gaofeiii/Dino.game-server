class LeagueApply < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	reference :league, League
	reference :player, Player

	attribute :player_nickname

	def to_hash
		{
			:id => id.to_i,
			:nickname => player_nickname
		}
	end
end
