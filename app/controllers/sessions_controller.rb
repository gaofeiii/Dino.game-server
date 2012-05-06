include SessionsHelper

class SessionsController < ApplicationController

	skip_before_filter :find_player

	def create
		player = Player.find(:account_id => params[:account_id]).first

		unless player
			player = create_player(params[:account_id])
		end

		login(player, params[:session_key])
		render :json => {:player_id => player.id.to_i}
	end
end
