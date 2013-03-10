class BuildingsController < ApplicationController

	before_filter :validate_village, :only => [:create]
	before_filter :validate_player, :only => [:speed_up, :harvest]
	before_filter :validate_building, :only => [:move, :complete, :harvest, :get_info]

	def create
		b_type = params[:building_type].to_i
		@player = @village.player

		# check if this kind of building existed
		# 判断建筑单一规则：
		# 1. 非资源建筑只能有一种
		# 2. 资源建筑受民居科技提供工人数的影响，
		if !b_type.in?(Building.resource_building_types) && @village.buildings.find(:type => b_type).any?
			error_msg = I18n.t("building_error.building_exist", :building_name => Building.get_locale_name_by_type(b_type))
			render_success(:player => @player.to_hash(:village), :info => error_msg)
			return
		end		

		if @player.curr_action_queue_size >= @player.action_queue_size
			# render :json => {
			# 	:message => Error.failed_message,
			# 	:error_type => Error::NORMAL,
			# 	:error => I18n.t('building_error.building_queue_is_full')
			# } and return
			render_success(:player => @player.to_hash(:village), :info => I18n.t('building_error.building_queue_is_full'))
			return
		end

		if @player.action_queue_size >= @village.res_buildings_size
			render_error(:player => @player.to_hash(:village), :info => I18n.t('building_error.not_enough_worker'))
			return
		end

		unless b_type.in?(Building.types)
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message("INVALID_BUILDING_TYPE")
			} and return
		end

		cost = Building.cost(b_type)

		if @player.spend!(cost)
			wkr = @player.working_workers < @player.total_workers && Building.resource_building_types.include?(b_type) ? 1 : 0
			@building = @village.create_building 	:type => b_type, 
																						:x => params[:x], 
																						:y => params[:y], 
																						:status => Building::STATUS[:new],
																						:has_worker => wkr

			data = {
				:message => Error.success_message, 
				:player => @player.to_hash(:queue_info).merge({:village => @village.to_hash.merge(:buildings => [@building.to_hash])})
			}
			render :json => data
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_res'))
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
			render_success(:player => @player.to_hash(:village), :info => I18n.t('building_error.building_finished'))
			return
		end

		if @player.spend!(:gems => @building.build_speed_up_gem_cost)
			# @building.update :status => 2, :start_building_time => 0
			@building.start_building_time = 0
			if @building.update_status!
				@player.earn_exp!(150)
			end
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gems')) and return
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
		if @building.update_status!
			@player = Player[@building.player_id]
			@player.earn_exp!(150)
		end
		render_success(:player => {:village => {:buildings => [@building.to_hash(:harvest_info)]}})
	end

	def move
		coord_x, coord_y = params[:x].to_i, params[:y].to_i
		if @building.update :x => coord_x, :y => coord_y
			render :json => {:message => Error.success_message}
		else
			render_error(Error::NORMAL, I18n.t('building_error.invalid_coords'))
		end
	end

	def destroy
		@building = Building[params[:building_id]]
		vil = Village.new :id => @building.village_id

		err = ""
		if @building.nil?
			err= I18n.t("building_error.building_destroyed")
		elsif @building.type == Building.hashes[:residential] && vil.buildings.find(:type => @building.type).size < 2
			err = I18n.t("building_error.keep_one_residential")
		end

		if err.empty?
			@building.delete
			@player = Player.new(:id => @building.player_id).gets(:wood, :stone, :gold_coin)
			render_success(:player => @player.resources)
		else
			render_error(Error::NORMAL, err)
		end
	end

	def harvest
		if not Building.resource_building_types.include?(@building.type)
			render_error(Error::NORMAL, "INVALID_RES_BUILDING_TYPE") and return
		end
		@building.update_harvest
		if @building.is_lumber_mill? || @building.is_quarry?
			res = Resource::TYPE[@building.harvest_type]
			@player.receive!(res => @building.harvest_count)

			# 判断是否出发神灵效果
			if @player.curr_god && @player.curr_god.type == God.hashes[:argriculture]
				@player.trigger_god_effect
				@player.gets(:wood, :stone)
			end

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
