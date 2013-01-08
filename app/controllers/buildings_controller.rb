class BuildingsController < ApplicationController

	before_filter :validate_village, :only => [:create]
	before_filter :validate_player, :only => [:speed_up, :harvest]
	before_filter :validate_building, :only => [:move, :complete, :destroy, :harvest, :get_info]

	def create
		@player = @village.player

		if @player.curr_action_queue_size >= @player.action_queue_size
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message("BUILDING_QUEUE_IS_FULL")
			} and return
		end

		type = params[:building_type].to_i
		unless type.in?(Building.types)
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message("INVALID_BUILDING_TYPE")
			} and return
		end

		cost = Building.cost(type)

		if @village.spend!(cost)
			@building = @village.create_building(params[:building_type], params[:x], params[:y], Building::STATUS[:new])
			data = {
				:message => Error.success_message, 
				:player => @player.to_hash(:queue_info).merge({:village => @village.to_hash.merge(:buildings => [@building.to_hash])})
			}
			render :json => data
		else
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message('NOT_ENOUGH_RESOURCES')
			}
		end
	end

	def speed_up
		@building = Building[params[:building_id]]

		if @building.nil?
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message("INVALID_BUILDING_ID")
			} and return
		end

		if @building.status >= 2
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message("BUILDING_IS_FINISHED")
			} and return
		end

		if @player.spend!(:gems => @building.build_speed_up_gem_cost)
			@building.update :status => 2, :start_building_time => 0
		else
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message("NOT_ENOUGH_SUNS")
			} and return
		end
		data = {
			:player => @player.to_hash.merge(
				:village => @player.village.to_hash.merge(
					:buildings => [@building.to_hash(:harvest_info)]
				)
			)
		}
		render_success(data)
	end

	def complete
		@building.update_status!
		render_success(:player => {:village => {:buildings => [@building.to_hash(:harvest_info)]}})
	end

	def move
		coord_x, coord_y = params[:x].to_i, params[:y].to_i
		if @building.update :x => coord_x, :y => coord_y
			render :json => {:message => Error.success_message}
		else
			render :json => {
				:message => Error.failed_message, 
				:error_type => Error::NORMAL,
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
				:error_type => Error::NORMAL,
				:error => Error.format_message(err)
			}
		end
	end

	def harvest
		if not Building.resource_building_types.include?(@building.type)
			render_error(Error::NORMAL, "This building cannot be harvested") and return
		end
		@building.update_harvest
		if @building.is_lumber_mill? || @building.is_quarry?
			res = Resource::TYPE[@building.harvest_type]
			@player.receive!(res => @building.harvest_count)
		elsif @building.is_collecting_farm? || @building.is_hunting_field?
			@player.receive_food!(@building.harvest_type, @building.harvest_count)
		end

		now_time = ::Time.now.to_i
		@building.harvest_count = 0
		@building.harvest_receive_time = @building.harvest_updated_time
		@building.harvest_updated_time = now_time

		if @building.is_collecting_farm?
			if now_time > @building.harvest_start_time + Building::HARVEST_CHANGE_TIME
				@building.harvest_type = rand(1..4)
				@building.harvest_start_time = now_time
			end
		elsif @building.is_hunting_field?
			if now_time > @building.harvest_start_time + Building::HARVEST_CHANGE_TIME
				@building.harvest_type = rand(5..8)
				@building.harvest_start_time = now_time
			end
		end

		@building.save

		data = {:player => @player.to_hash(:resources, :specialties)}
		render_success(data)
	end

	def get_info
		data = {
			:player => {
				:village => {
					:buildings => [@building.to_hash(:harvest_info)]
				}
			}
		}
		render_success(data)
	end
end
