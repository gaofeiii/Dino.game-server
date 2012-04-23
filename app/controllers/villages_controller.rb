class VillagesController < ApplicationController

	def index
		player = Player[params[:player_id]]

		unless player
			render :json => "Player not found", :status => 999 and return
		end
		render :json => player.village
	end
end
