class VillagesController < ApplicationController

	before_filter :validate_village
	def index
		player = Player[params[:player_id]]

		unless player
			render :json => "Player not found", :status => 999 and return
		end
		data = {:message => "OK", :player => player.to_hash(:all)}
		render :json => player.village
	end

	def move
		player = @village.player

		if player.spend!(:gems => 100)
			@village.update :x => params[:x], :y => params[:y], :index => 0
			render_success(:player => player.to_hash.merge(:village => @village.to_hash))
		else
			render_error(Error::NORMAL, "NOT_ENOUGH_GEMS")
		end
	end

end
