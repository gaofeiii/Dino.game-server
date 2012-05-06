class PlayersController < ApplicationController

	def index
		player = Session.with(:session_key, params[:session_key]).try(:player)
		if player.nil?
			render :json => {:error => "Player not found"}, :status => 999 and return
		end
		render :json => {:player => player}
	end

	def show
		player = Player[params[:id]]
		if player.nil?
			render :json => {:error => "Player not found"}, :status => 999 and return
		end
		render :json => {:player => player}
	end
end
