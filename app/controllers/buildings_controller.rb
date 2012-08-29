class BuildingsController < ApplicationController

	before_filter :validate_village, :only => [:create]
	before_filter :validate_player, :only => [:speed_up]

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

	def speed_up
		building = Building[params[:building_id]]

		if building.nil?
			render :json => {:error => "INVALID_BUILDING_ID"} and return
		end

		if building.status >= 2
			render :json => {:error => "BUILDING_IS_FINISHED"} and return
		end

		if @player.spend!(BUILDING_SPEED_UP_COST)
			building.update :status => 2, :start_building_time => 0
		else
			render :json => {:error => "NOT_ENOUGH_SUNS"} and return
		end

		render :json => {:message => "OK", :player => @player.to_hash(:village)}

	end
end
