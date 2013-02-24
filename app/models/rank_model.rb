module RankModel
	module ClassMethods

		# The class must have attribute: battle_power
		def battle_rank(count = 20)
			result = []

			Player.none_npc.sort_by(:honour_score, :order => "DESC", :limit => [0, count]).each_with_index do |player, idx|
				result << {
					:id => player.id,
					:rank => idx + 1,
					:battle_power => player.honour_score,
					:nickname => player.nickname,
					:level => player.level
				}
			end

			return result
		end
	end
	
	module InstanceMethods
		
		def to_rank_hash
			{
				:id => id,
				:rank => 1,
				:battle_power => battle_power,
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