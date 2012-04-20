# TODO: [S] 完成建造建筑的功能

class BuildingsController < ApplicationController

	def create
		village = Village[params[:village_id]]
		if village.nil?
			render :json => {:error => "Village not found"}, :status => 999 and return
		end
		village.create_building(params[:building_type])
		render :json => village
	end
end
