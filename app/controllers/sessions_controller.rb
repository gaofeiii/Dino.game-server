include SessionsHelper

class SessionsController < ApplicationController

	def create
		player = Player.find_by_account_id(params[:account_id])

		unless player
			player = create_player(params[:account_id])
		end

		login(player, params[:session_key])
		render :json => "OK"
	end
end
