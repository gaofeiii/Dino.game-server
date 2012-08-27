class BuildingsController < ApplicationController

	before_filter :validate_village, :only => [:create]

	def create
		type = params[:building_type].to_i
		unless type.in?(Building.types)
			render :json => {:error => "INVALID_BUILDING_TYPE"}, :status => 999 and return
		end

		cost = BUILDINGS[type][:cost]

		if @village.spend!(cost)
			@village.create_building(params[:building_type], params[:x], params[:y])
			data = {:message => "OK", :player => {:village => @village.to_hash(:buildings)}}
			render :json => data
		else
			render :json => {:error => 'NOT_ENOUGH_RESOURCES'}
		end

	end
end
