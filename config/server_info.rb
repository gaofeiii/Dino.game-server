require 'socket'

class Hash
	def deep_symbolize_keys
    inject({}) { |result, (key, value)|
      value = value.deep_symbolize_keys if value.is_a?(Hash)
      result[(key.to_sym rescue key) || key] = value
      result
    }
  end unless Hash.method_defined?(:deep_symbolize_keys)
end

class ServerInfo
	# include OhmExtension

	@@cache = Hash.new

	class << self

		def reload!
			@@cache = YAML::load_file("#{Dir::pwd}/config/server_config.yml").deep_symbolize_keys
		end

		def all
			if @@cache.empty?
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
