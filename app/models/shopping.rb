class Shopping

	SPECAIL_GOODS_TYPE = {
		:vip => 1,
		:on_sale => 2,
		:num_limit => 3
	}

	MATCH_COUNT_COST = 20

	QUALITY_VALS = [1, 2, 3, 4, 5]
	EGG_TYPES_VALS = [1, 2, 3, 4, 5, 6, 7, 8, 9]

	PRODUCT_ID_TO_SID = {
		"com.dinosaur.gems.usd499" => 1001,
	    "com.dinosaur.gems.usd999" => 1002,
	    "com.dinosaur.gems.usd1999" => 1003,
	    "com.dinosaur.gems.usd4999" => 1004,
	    "com.dinosaur.gems.usd9999" => 1005,
	    "com.gaofei.dinostyle2.gems.us499" => 1001,
	    "com.gaofei.dinostyle2.gems.us999" => 1002,
	    "com.gaofei.dinostyle2.gems.us1999" => 1003,
	    "com.gaofei.dinostyle2.gems.us4999" => 1004,
	    "com.gaofei.dinostyle2.gems.us9999" => 1005,
	}


	include ShoppingConst

	class << self
		def iap_product_ids
			list[:gems].map{|x| x[:product_id]}
		end

		def find_iap_info_by_product_id(product_id)
			self.list[:gems].each do |itm|
				return itm if itm[:product_id] == product_id
			end
			nil
		end

		def find_sid_by_product_id(product_id)
			# itm = find_iap_info_by_product_id(product_id)
			# return itm[:sid] if itm
			PRODUCT_ID_TO_SID[product_id]
		end

		def find_first_reward_by_sid(sid)
			first_time_rewards[sid]
		end

		def find_gems_count_by_product_id(product_id)
			itm = find_iap_info_by_product_id(product_id)
			
			return itm[:count] if itm
		end

		def find_iap_price_by_product_id(product_id)
			itm = find_iap_info_by_product_id(product_id)

			return itm[:price] if itm
		end

		def get_rand_egg(sid)
			info = self.eggs_drops[sid]
			return false unless info

			egg_type = Tool.range_drop(info[:egg_types_odds], EGG_TYPES_VALS)
			quality = Tool.range_drop(info[:quality_odds], QUALITY_VALS)
			return false unless egg_type && quality

			{:item_category => Item::EGG, :item_type => egg_type, :quality => quality}
		end

		def buy_random_egg(sid: nil, player_id: nil)
			egg = get_rand_egg(sid)

			Item.create egg.merge(:player_id => player_id)
		end
		
	end

end