module SessionsHelper
	def login(player, session_key)
		sess = Session.create :session_key => session_key, :expired_time => Time.now + 1.day, :player_id => player.id
		player.update :session_id => sess.id
	end

	def create_player(account_id)
		Player.create :account_id => account_id
	end
end
