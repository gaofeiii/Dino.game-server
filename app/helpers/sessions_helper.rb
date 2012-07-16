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

	def account_authenticate(params = {})
		http_post "#{ACCOUNT_SERVER}:#{ACCOUNT_PORT}/signin", params
	end

	def account_register
		http_post "#{ACCOUNT_SERVER}:#{ACCOUNT_PORT}/signup", params
	end

	def http_get(address)
		uri = URI.parse create_url(address)
		res = Net::HTTP.get_response uri
		data = JSON.parse(res.body).deep_symbolize_keys
	end

	def http_post(address, params = {})
		uri = URI.parse create_url(address)
		res = Net::HTTP.post_form uri, params
	end

	def create_url(address)
		if address.downcase =~ /http:\/\//
			address
		else
			"http://#{address}"
		end
	end
end
