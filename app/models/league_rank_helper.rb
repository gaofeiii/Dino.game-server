module LeagueRankHelper
	module ClassMethods

		def update_all_battle_rank!
			result = []

			League.all.ids.each do |_league_id|
				_league = League.new(:id => _league_id)
				record = _league.members.ids.sum do |_member_id|
					score = db.hget(Player.key[_member_id], :honour_score).to_i
					score
				end
				_league.set :total_battle_power, record

				result << record
				result << _league.id
			end

			db.del League.key[:battle_rank]
			db.zadd League.key[:battle_rank], result
		end
		
		def battle_rank(count = 20)
			# self.all.each do |league|
			# 	record = league.members.ids.sum do |member_id|
			# 		db.hget("Player:#{member_id}", :battle_power).to_i
			# 	end
			# 	league.update :total_battle_power => record if league.total_battle_power != record
			# end
			result = []

			league_ids = db.zrevrangebyscore(League.key[:battle_rank], '+inf', '-inf', :limit => [0, count])
			league_ids.each do |_league_id|
				_league = League.new(:id => _league_id).gets(:name, :level, :total_battle_power)

				result << {
					:id => _league.id,
					:name => _league.name,
					:rank => _league.my_league_rank,
					:total_battle_power => _league.total_battle_power,
					:level => _league.level,
					:member_count => _league.members.count
				}
			end

			result
		end # End of def battle_rank

	end
	
	module InstanceMethods
		
		def my_league_rank
			db.zrevrank(League.key[:battle_rank], id).to_i + 1
		end

		def update_my_league_rank
			record = members.ids.sum do |_member_id|
				score = db.hget(Player.key[_member_id], :honour_score).to_i
				score
			end
			db.zadd(League.key[:battle_rank], record, id)
		end

		def after_create
			update_my_league_rank
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end