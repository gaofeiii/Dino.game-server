# Just included by Player
module PlayerBattleRankHelper
	module ClassMethods
		
		# Note: Just used in background. Should not be called during player's request methods.
		def update_all_battle_rank!
			result = []
			self.none_npc.ids.each do |_player_id|
				_player = self.new(:id => _player_id).gets(:honour_score)
				result << _player.honour_score
				result << _player_id
			end

			db.del self.key[:battle_rank]
			db.zadd self.key[:battle_rank], result
		end

		def battle_rank(count = 20)
			result = []

			player_ids = db.zrevrangebyscore(Player.key[:battle_rank], '+inf', '-inf', :limit => [0, count])
			player_ids.each do |_player_id|
				_player = Player.new(:id => _player_id).gets(:honour_score, :nickname, :level)
				result << {
					:id => _player.id,
					:rank => _player.my_battle_rank,
					:nickname => _player.nickname,
					:level => _player.level,
					:battle_power => _player.honour_score
				}
			end

			return result
		end
	end
	
	module InstanceMethods
		
		def my_battle_rank
			db.zrevrank(Player.key[:battle_rank], id).to_i + 1
		end

		def to_rank_hash
			{
				:id => id,
				:rank => my_battle_rank,
				:battle_power => honour_score,
				:nickname => nickname,
				:level => level
			}
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end