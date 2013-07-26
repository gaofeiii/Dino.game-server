require 'yaml'
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

module ServerHelper

	module RedisHelper
		def host
			self[:host]
		end

		def port
			self[:port]
		end

		def address
			"#{host}:#{port}"
		end
	end
	
	def redis
		self[:redis].extend(RedisHelper)
	end
end

module ServerEnvHelper
	def dev?
		self == "dev"
	end

	alias debug? dev?

	def production?
		self == "production"
	end

end

class GameServer
	@@cache = Hash.new

	class << self

		def load!
			@@cache = YAML::load_file("#{Dir::pwd}/config/server_config.yml").deep_symbolize_keys
		end

		def all
			if @@cache.empty?
				load!
			else
				@@cache
			end
		end

		def server_name
			@@server_name ||= Socket.gethostname.to_sym
			@@server_name
		end

		def info
			all[server_name].extend(ServerHelper)
		end
		alias current info

		def env
			current[:env].extend(ServerEnvHelper)
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

		def default_locale
			current[:default_locale].to_sym
		end

		def server_data
			shop_list = Shopping.list
			shop_list[:vip].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])}
			shop_list[:protection].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])}
			shop_list[:lottery].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])}
			shop_list[:scrolls].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])}
			shop_list[:eggs].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])}
			shop_list[:gems].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])}

			{
				:data => {
					:version => GameServer.info[:info_const_version],
					:buildings => Building.cost,
					:guide_reward => Player.beginning_guide_reward,
					:shopping_list => shop_list,
					:speed_up_info => {
						:building => 300,
						:tech => 300,
						:hatch_speed_up => 300
					},
					:god_cost => {
						:wood => 1000,
						:stone => 1000,
						:gold => 1000
					},
					:lottery_reward => LuckyReward.const(1).values,
					:league_gold_cost => 1000,
					:move_town_gems_cost => 50,
					:cave_rewards => PlayerCave.all_star_rewards,
					:gold_mine_upg_data => GoldMine.upgrade_cost
				}
			}
		end

		def export_server_data
			content = server_data[:data].to_json
			file = File.new("/Users/gaofei/magic/dinosaur/linode_svn/game-client/PhoneGame/Resource/game_data/server_data.json", "w")
			file.write(content)
			file.close
		end

		def export_tech_data
			file = File.new("/Users/gaofei/magic/dinosaur/linode_svn/game-client/PhoneGame/Resource/game_data/tech.json", "w")
			file.write(Technology.const.to_json)
			file.close
		end

	end
end
