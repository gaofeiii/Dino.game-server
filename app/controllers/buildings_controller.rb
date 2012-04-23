class BuildingsController < ApplicationController

	def create
		unless BUILDING_TYPES.include?(params[:building_type].to_i)
			render :json => {:error => "Invalid building type"}, :status => 999 and return
		end

		player = Player[params[:player_id]]
		if player.nil?
			render :json => {:error => "Player not found"}, :status => 999 and return
		end

		village = Village[params[:village_id]]
		if village.nil?
			render :json => {:error => "Village not found"}, :status => 999 and return
		end

		village.create_building(params[:building_type], params[:x], params[:y])
		render :json => player.full_info
	end
end
