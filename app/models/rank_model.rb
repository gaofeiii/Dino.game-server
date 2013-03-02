module RankModel
	module ClassMethods

	end
	
	module InstanceMethods
		
		def to_rank_hash
			{
				:id => id,
				:rank => 1,
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