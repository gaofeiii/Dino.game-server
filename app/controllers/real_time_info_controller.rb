class RealTimeInfoController < ApplicationController

	def info
		data = {
			:data => {
				:buildings => Building.cost,
				:technologies => Technology.cost,
				:guide_reward => Player.beginning_guide_reward,
				:shopping_list => Shopping.list
			}
		}
			
		render_success(data)
	end
end
