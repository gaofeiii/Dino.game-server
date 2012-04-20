class PlayersController < ApplicationController

	def show
		player = Player[params[:id]]
		if player.nil?
			render :json => {:error => "Player not found"}, :status => 999 and return
		end
		render :json => {:player => player}
	end
end
