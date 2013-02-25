require 'socket'

class ServerInfo
	# include OhmExtension

	@@cache = Hash.new

	class << self

		def reload!
			@@cache = YAML::load_file("#{Rails.root}/config/server_config.yml").deep_symbolize_keys
		end

		def all
			if @@cache.blank?
				reload!
			else
				@@cache
			end
		end

		def server_name
			@@server_name ||= Socket.gethostname.to_sym
			@@server_name
		end

		def info
			all[server_name]
		end

		def account_server
			"http://#{info[:account_server_ip]}:#{info[:account_server_port]}"
		end

		def const_version
			all[server_name][:info_const_version]
		end

		def account_server_private_key
			"HYidrqowAYYhTtYK8UthqBIO6bPBRcAzbEeQHyhehW0c2Rmm53zYyqteoJX3lFKqTTpPT5Y0mk8uoY"
		end

		def cli_pri_key
			"PZAaCr854VtQNcDrTSwBYyvfus0zZauY1Dg3WO4A45lL60LwBA1LbBXxmmAltcLqzhhMImi48oq7iK"
		end

		# def info
		# 	SERVER_INFO[server_name]
		# end

		# def account_server
		# 	"http://#{info[:account_server_ip]}:#{info[:account_server_port]}"
		# end
	end
end
