require 'net/http'

module SessionsHelper
	# 与账户服务器交互的方法	

	def account_authenticate(params = {})
		HttpHelper.send_post "#{ServerInfo.account_server}/signin", params
	end

	def account_register(params = {})
		HttpHelper.send_post "#{ServerInfo.account_server}/signup", params
	end

	def account_update(params = {})
		HttpHelper.send_post "#{ServerInfo.account_server}/update", params
	end

	def account_change_pass(params = {})
		HttpHelper.send_post "#{ServerInfo.account_server}/change_pass", params
	end

	def send_push_message(params = {})
		HttpHelper.send_post "#{ServerInfo.account_server}/send_apn", params
	end

	def trying(params = {})
		HttpHelper.send_post "#{ServerInfo.account_server}/try_playing", params
	end

	def generate_session_key(player)
		Digest::MD5.hexdigest("#{player.nickname}:#{Time.now.to_s}:#{String.sample(4)}")
	end

end
