module SessionsHelper
	def login(player, session_key)
		sess = Session.create :session_key => session_key, :expired_at => Time.now.utc + 1.hour, 
													:player_id => player.id
		player.update :session_id => sess.id
	end

	def create_player(account_id, nickname = nil)
		n_name = nickname.nil? ? "Player_#{Digest::MD5.hexdigest(Time.now.utc.to_s + String.sample(6))}" : nickname
		Player.create :account_id => account_id, :nickname => n_name
	end
end
