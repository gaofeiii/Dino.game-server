class LeagueInvitation < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :mail_id
	attribute :league_id

	reference :player,		Player
	reference :league, 		League

	def mail
		if @mail.nil?
			@mail = Mail[mail_id]
		end
		@mail
	end
end
