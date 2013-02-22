module RankModel
	module ClassMethods

		# The class must have attribute: battle_power
		def battle_rank(count = 20)
			result = []

			Player.none_npc.sort_by(:battle_power, :order => "DESC", :limit => [0, count]).each_with_index do |player, idx|
				result << {
					:id => player.id,
					:rank => idx + 1,
					:battle_power => player.battle_power,
					:nickname => player.nickname,
					:level => player.level
				}
			end

			return result
		end
	end
	
	module InstanceMethods
		
		def to_rank_hash
			
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end