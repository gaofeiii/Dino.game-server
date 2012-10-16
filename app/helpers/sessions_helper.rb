module SessionsHelper
	
	# 与账户服务器交互的方法	

	def account_authenticate(params = {})
		http_post "#{ServerInfo.account_server}/signin", params
	end

	def account_register(params = {})
		http_post "#{ServerInfo.account_server}/signup", params
	end

	def account_update(params = {})
		http_post "#{ServerInfo.account_server}/update", params
	end

	def send_push_message(params = {})
		http_post "#{ServerInfo.account_server}/send_apn", params
	end

	def trying
		http_get("#{ServerInfo.account_server}/try_playing")
	end

	def login(player, session_key)
		sess = Session.create :session_key => session_key, :expired_at => ::Time.now.utc + 1.hour, 
													:player_id => player.id
		player.update :session_id => sess.id
	end


	
	# 私有方法
	# private
	def http_get(address)
		uri = URI.parse create_url(address)
		res = Net::HTTP.get_response uri
		data = JSON.parse(res.body).deep_symbolize_keys
	end

	def http_post(address, params = {})
		uri = URI.parse create_url(address)
		res = Net::HTTP.post_form uri, params
		p "response: ", res.body
		data = JSON.parse(res.body).deep_symbolize_keys
	end

	def create_url(address)
		if address.downcase =~ /http:\/\//
			address
		else
			"http://#{address}"
		end
	end
end
