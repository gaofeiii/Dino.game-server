# Only included by GoldMine model.
module GoldMineLeagueHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		def add_attacking_count(league_id)
			# league_id => count
			db.hincrby(league_info_key, league_id, 1)
		end
		
		def league_info_key
			key[:league_info]
		end

		def league_info
			info = {}
			db.hgetall(league_info_key).each do |key, val|
				info[key.to_i] = val.to_i
			end
			info
		end

		def winner_league_id
			max_count = -1
			winner_id = -1
			league_info.each do |league_id, count|
				count = count.to_i
				if count > max_count
					winner_id = league_id
					max_count = count
				end
			end
			winner_id.to_i
		end

		def get_league_rank(league_id)
			info = league_info
			league_count = info[league_id]
			return 999 if league_count.blank?

			ordered_vals = info.values.sort!.reverse!
			ordered_vals.index(league_count) + 1
		end

		def reset_league_info
			db.del league_info_key
		end
	end
	
	def self.included(model)
		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end