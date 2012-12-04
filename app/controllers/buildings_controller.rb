class BuildingsController < ApplicationController

	before_filter :validate_village, :only => [:create]
	before_filter :validate_player, :only => [:speed_up]
	before_filter :validate_building, :only => [:move, :destroy]

	def create
		@player = @village.player
		puts "$$$ @player.curr_action_queue_size: #{@player.curr_action_queue_size}"
		puts "$$$ @player.action_queue_size: #{@player.action_queue_size}"
		if @player.curr_action_queue_size >= @player.action_queue_size
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::TYPES[:normal],
				:error => Error.format_message("BUILDING_QUEUE_IS_FULL")
			} and return
		end

		type = params[:building_type].to_i
		unless type.in?(Building.types)
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("INVALID_BUILDING_TYPE")
			} and return
		end

		cost = Building.cost(type)

		if @village.spend!(cost)
			@village.create_building(params[:building_type], params[:x], params[:y], Building::STATUS[:new])
			data = {:message => Error.success_message, :player => {:village => @village.to_hash(:buildings)}}
			render :json => data
		else
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message('NOT_ENOUGH_RESOURCES')
			}
		end

	end

	def speed_up
		building = Building[params[:building_id]]

		if building.nil?
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("INVALID_BUILDING_ID")
			} and return
		end

		if building.status >= 2
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("BUILDING_IS_FINISHED")
			} and return
		end

		if @player.spend!(BUILDING_SPEED_UP_COST)
			building.update :status => 2, :start_building_time => 0
		else
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("NOT_ENOUGH_SUNS")
			} and return
		end

		render :json => {:message => Error.success_message, :player => @player.to_hash(:village)}

	end

	def move
		coord_x, coord_y = params[:x].to_i, params[:y].to_i
		if @building.update :x => coord_x, :y => coord_y
			render :json => {:message => Error.success_message}
		else
			render :json => {
				:message => Error.failed_message, 
				:error_type => Error.types[:normal],
				:error => Error.format_message("invalid coordinate")
			}
		end
	end

	def destroy
		@building.delete
		if not Building.exists?(@building.id)
			render :json => {:message => Error.success_message}
		else
			# TODO: Some building cannot be destroyed because it is running something, like hatching.
			# 			Note the reason in error info.
			err = "Error condition"
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message(err)
			}
		end
	end
end
