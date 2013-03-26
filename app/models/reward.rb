module Reward

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