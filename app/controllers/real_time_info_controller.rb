class RealTimeInfoController < ApplicationController

	def info
		data = {
			:data => {
				:buildings => Building.cost,
				:technologies => Technology.cost,
				:guide_reward => Player.beginning_guide_reward,
				:shopping_list => Shopping.list,
				:dinosaurs => {:recovery_speed => 60}, # 等级*60秒
				:speed_up_info => {
					:building => 300, # 每300消耗1个宝石
					:tech => 300,
					:dino_hp_recovery => 300
				}
			}
		}
			
		render_success(data)
	end
end
