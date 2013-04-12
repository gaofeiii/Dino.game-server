module PlayerRewardHelper
	module ClassMethods
		
	end
	
	module InstanceMethods

		def get_reward(reward = nil)
			return false unless reward && reward.is_a?(Reward)

			has_wood 	= reward.wood > 0
			has_stone = reward.stone > 0
			has_gold 	= reward.gold_coin > 0
			has_gems	= reward.gems > 0
			has_xp 		= reward.xp > 0

			re = db.multi do |t|
				t.hincrby(key, :wood, reward.wood.to_i) if has_wood
				t.hincrby(key, :stone, reward.stone.to_i) if has_stone
				t.hincrby(key, :gold_coin, reward.gold_coin.to_i) if has_gold
				t.hincrby(key, :gems, reward.gems.to_i) if has_gems
				t.hincrby(key, :experience, reward.xp.to_i) if has_xp
			end

			changed_atts = []
			changed_atts << :wood 			if has_wood
			changed_atts << :stone 			if has_stone
			changed_atts << :gold_coin 	if has_gold
			changed_atts << :gems 			if has_gems
			changed_atts += [:experience, :level] if has_xp

			gets(*changed_atts) if changed_atts.any?

			update_level if has_xp

			# 接收物品array
			unless reward.items.blank?
				reward.items.each do |item|
					if item.is_food?
						self.receive_food!(item.type, item.count)
					else
						Item.create(:item_category => item.category, :item_type => item.type, :quality => item.quality, :player_id => id)
					end
				end
			end

			return self
		end
		
		# Reward Structure:
		# {
		# 	:wood => 1,
		# 	:stone => 1,
		# 	:gold => 2, :gold_coin => 2,
		# 	:items => [{
		# 		:item_cat => 1,
		# 		:item_type => 1,
		# 		:item_count => 1,
		# 		:quality => 1
		# 	}]
		# }
		def receive_reward!(reward = {})
			return false if reward.blank?

			self.receive!(reward)
			self.earn_exp!(reward[:xp]) if reward.has_key?(:xp)

			if reward.has_key?(:items)
				reward[:items].each do |itm|
					if itm[:item_cat] == Item.categories[:food]
						self.receive_food!(itm[:item_type], itm[:item_count])
					else
						Item.create(:item_category => itm[:item_cat], :item_type => itm[:item_type], :quality => itm[:quality], :player_id => id)
					end
				end
			end
		end

	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end