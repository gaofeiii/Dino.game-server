class VillagesController < ApplicationController

	def index
		player = Player[params[:player_id]]
		render :json => {:village => player.try(:village)}
	end
end
