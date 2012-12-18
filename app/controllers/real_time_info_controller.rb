class RealTimeInfoController < ApplicationController

	before_filter :validate_player, :only => [:info]

	def info
		data = {
			:data => {
				:buildings => Building.cost,
				:technologies => Technology.cost
			}
		}
			
		render_sucess(data)
	end
end
