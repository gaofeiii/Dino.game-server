require 'net/http'

module SessionsHelper

	def test_log_info
		p "--- account server: #{ServerInfo.account_server} ---"
	end
	
	# 与账户服务器交互的方法	

	def account_authenticate(params = {})
		test_log_info
		http_post "#{ServerInfo.account_server}/signin", params
	end

	def account_register(params = {})
		http_post "#{ServerInfo.account_server}/signup", params
	end

	def account_update(params = {})
		http_post "#{ServerInfo.account_server}/update", params
	end

	def account_change_pass(params = {})
		http_post "#{ServerInfo.account_server}/change_pass", params
	end

	def send_push_message(params = {})
		http_post "#{ServerInfo.account_server}/send_apn", params
	end

	def trying(params = {})
		test_log_info
		http_post("#{ServerInfo.account_server}/try_playing", params)
	end

	def login(player, session_key)
		sess = Session.create :session_key => session_key, :expired_at => ::Time.now.utc + 1.hour, 
													:player_id => player.id
		player.update :session_id => sess.id
	end

	def generate_session_key(player)
		Digest::MD5.hexdigest("#{player.nickname}:#{Time.now.to_s}:#{String.sample(4)}")
	end


	
	# 私有方法
	# private
	def http_get(address)
		uri = URI.parse create_url(address)

		req = Net::HTTP::Get.new(uri.request_uri)
		currTime = ::Time.now.to_i
		req['Date'] = currTime.to_s
		req['Sig'] = Digest::MD5.hexdigest("#{req.fullpath}--#{currTime}--#{ServerInfo.account_server_private_key}")

		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
			http.request(req)
		end

		# res = Net::HTTP.get_response uri
		data = JSON.parse(res.body).deep_symbolize_keys
		p "--- account server data ---", data
		data
	end

	def http_post(address, params = {})
		uri = URI.parse create_url(address)

		req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json'})
		req['SIG'] = "abc"

		req.body = params.to_json

		currTime = ::Time.now.to_i
		req['Date'] = currTime.to_s
		req['Sig'] = Digest::MD5.hexdigest("#{params.to_json}--#{currTime}--#{ServerInfo.account_server_private_key}")
		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
			http.request(req)
		end

		# res = Net::HTTP.post_form uri , params
		data = JSON.parse(res.body).deep_symbolize_keys
		p "--- account server data ---", data
		data
	end

	def create_url(address)
		if address.downcase =~ /http:\/\//
			address
		else
			"http://#{address}"
		end
	end
end
