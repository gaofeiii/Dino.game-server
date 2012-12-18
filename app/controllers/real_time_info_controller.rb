class RealTimeInfoController < ApplicationController

	def info
		data = {
			:data => {
				:buildings => Building.cost,
				:technologies => Technology.cost
			}
		}
			
		render_success(data)
	end
end
