class ServerInfo

	class << self

		def server_name
			unless Ohm.redis.exists(:server_name)
				raise "'server_name' doesn't exist in Redis. Please set it before starting everything."
			end

			Ohm.redis.get(:server_name).to_sym
		end

		def server_name=(name)
			Ohm.redis.set :server_name, name
		end

		def info
			SERVER_INFO[server_name]
		end

		def account_server
			"http://#{info[:account_server_ip]}:#{info[:account_server_port]}"
		end
	end
end
