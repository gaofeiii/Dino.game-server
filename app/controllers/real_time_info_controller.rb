class RealTimeInfoController < ApplicationController

	def info
		render :json => {
			:data => {
					:buildings => Building.cost,
					:technologies => Technology.cost
			}
		}
	end
end
