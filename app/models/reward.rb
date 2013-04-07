RewardItem = Struct.new(:category, :type, :count, :quality) do
	
	def to_hash
		{
			:item_cat 	=> self.category,
			:item_type 	=> self.type,
			:count 			=> self.count,
			:quality 		=> self.quality
		}
	end
	alias values to_hash

	def is_food?
		self.category == Item::CATEGORIES[:food]
	end
end

class Reward
	attr_accessor :wood, :stone, :gold_coin, :gems, :items, :xp

	# items是由item组成的数组,
	# item.is_a?(RewardItem) # => true
	def initialize(wood:0, stone:0, gold:0, gold_coin:0, gem:0, gems:0, items:[], item:nil, xp:0)
		self.wood = wood
		self.stone = stone
		self.gold_coin = gold | gold_coin
		self.gems = gem | gems
		self.items = items
		self.items << item if item && item.is_a?(RewardItem)
		self.xp = xp
	end

	def self.monster_rewards(target_type) # 1..20
		origin = Monster.rewards[target_type]

		reward = Reward.new

		case rand(1..1000)
		when 1..900
			reward.gold_coin = origin[:res_count]
		when 901..950
			reward.items << RewardItem.new(Item.categories[:egg], origin[:egg_type].sample, 1, 1)
		when 951..1000
			reward.items << RewardItem.new(Item.categories[:scroll], origin[:scroll_type].sample, 1)
		end

		reward
	end

	def to_hash
		hash = {}
		hash[:wood] 			= wood
		hash[:stone] 			= stone
		hash[:gold_coin] 	= gold_coin
		hash[:xp] 				= xp
		hash[:items] 			= items unless items.blank?
		hash
	end
	alias values to_hash

end

module ModReward

	def judge!(target_type) # 1..20
		origin = Monster.rewards[target_type]

		reward = {}
		case rand(1..1000)
		# when 1..300
		# 	reward = {
		# 		:items => [{
		# 			:item_cat => Item.categories[:food], 
		# 			:item_type => Specialty.types.sample, 
		# 			:item_count => origin[:food_count]
		# 		}]
		# 	}
		when 1..900
			reward = {
				# :wood => origin[:res_count],
				# :stone => origin[:res_count],
				:gold_coin => origin[:res_count]
			}
		when 901..950
			reward = {
				:items => [{
					:item_cat => Item.categories[:egg], 
					:item_type => origin[:egg_type].sample, 
					:item_count => 1
				}]
			}
		when 951..1000
			reward = {
				:items => [{
					:item_cat => Item.categories[:scroll],
					:item_type => origin[:scroll_type].sample,
					:item_count => 1
				}]
			}
		end
		reward
	end
	
	module_function :judge!

end