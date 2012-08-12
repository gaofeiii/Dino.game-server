class BuildingsController < ApplicationController

	before_filter :validate_village, :only => [:create]

	def create
		unless BUILDING_TYPES.include?(params[:building_type].to_i)
			render :json => {:error => "INVALID_BUILDING_TYPE"}, :status => 999 and return
		end

		@village.create_building(params[:building_type], params[:x], params[:y])
		data = {:message => "OK", :player => {:village => @village.to_hash(:buildings)}}
		render :json => data
	end
end
