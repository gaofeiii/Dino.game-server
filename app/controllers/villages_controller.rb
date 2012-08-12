class VillagesController < ApplicationController

	def index
		player = Player[params[:player_id]]

		unless player
			render :json => "Player not found", :status => 999 and return
		end
		data = {:message => "OK", :player => player.to_hash(:all)}
		render :json => player.village
	end

end
