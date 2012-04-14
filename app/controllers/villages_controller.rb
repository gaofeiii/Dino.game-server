class VillagesController < ApplicationController

	def index
		p Ohm.redis.info
		player = Player[params[:player_id]]
		render :json => player.try(:village)
	end
end
