class RealTimeInfoController < ApplicationController

	before_filter :validate_player

	def refresh
		render :json => []
	end
end
