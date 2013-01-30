class RealTimeInfoController < ApplicationController

	skip_filter :validate_sig

	def info
		data = {
			:data => {
				:buildings => Building.cost,
				:technologies => Technology.cost,
				:guide_reward => Player.beginning_guide_reward,
				:shopping_list => Shopping.list,
				:dinosaurs => {:recovery_speed => 60}, # 等级*60秒
				:speed_up_info => {
					:building => 300, # 每300秒消耗1个宝石
					:tech => 300,
					:dino_hp_recovery => 300,
					:hatch_speed_up => 300
				},
				:god_cost => {
					:wood => 1000,
					:stone => 1000,
					:gold => 1000
				},
				:lottery_reward => LuckyReward.const(1).values
			}
		}
			
		render_success(data)
	end
end
