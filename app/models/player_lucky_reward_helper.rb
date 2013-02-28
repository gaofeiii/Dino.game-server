module PlayerLuckyRewardHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		
		def receive_lucky_reward(reward)
			return nil if reward.blank?

			case reward[:reward_cat]
			when LuckyReward.categories[:wood]
				self.receive!(:wood => reward[:count])
			when LuckyReward.categories[:stone]
				self.receive!(:stone => reward[:count])
			when LuckyReward.categories[:gold]
				self.receive!(:gold => reward[:count])
			when LuckyReward.categories[:food]
				self.receive_food!(reward[:type], reward[:count])
			when LuckyReward.categories[:egg]
				Item.create(:item_category => Item.categories[:egg], :item_type => reward[:type], :player_id => id)
			when LuckyReward.categories[:scroll]				
				Item.create(:item_category => Item.categories[:scroll], :item_type => reward[:type], :player_id => id)
			else
				nil
			end
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end