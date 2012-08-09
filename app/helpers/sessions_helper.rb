module SessionsHelper
	

	def account_authenticate(params = {})
		http_post "#{ACCOUNT_SERVER}:#{ACCOUNT_PORT}/signin", params
	end

	def account_register(params = {})
		http_post "#{ACCOUNT_SERVER}:#{ACCOUNT_PORT}/signup", params
	end

	def login(player, session_key)
		sess = Session.create :session_key => session_key, :expired_at => ::Time.now.utc + 1.hour, 
													:player_id => player.id
		player.update :session_id => sess.id
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
