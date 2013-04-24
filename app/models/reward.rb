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

	def is_scroll?
		self.category == Item::CATEGORIES[:scroll]
	end
end

class Reward
	attr_accessor :wood, :stone, :gold_coin, :gems, :items, :xp

	def initialize(wood:0, stone:0, gold:0, gold_coin:0, gem:0, gems:0, items:[], item:nil, xp:0)
		self.wood = wood
		self.stone = stone
		self.gold_coin = gold | gold_coin
		self.gems = gem | gems

		self.items = items
		self.items << item if item

		obj_items = self.items.map do |itm|
			if itm.is_a?(RewardItem)
				itm
			else
				RewardItem.new(itm[:item_cat], itm[:item_type], itm[:item_count] || itm[:count], itm[:quality]) if itm[:item_cat] > 0
			end
		end
		self.items = obj_items.compact

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
		hash[:wood] 			= wood if wood > 0
		hash[:stone] 			= stone if stone > 0
		hash[:gold_coin] 	= gold_coin if gold_coin > 0
		hash[:xp] 				= xp if xp > 0
		hash[:items] 			= items.map(&:to_hash) unless items.blank?
		hash
	end
	alias values to_hash

end