class ResearchController < ApplicationController

	before_filter :validate_player

	def research
		if @player.curr_research_queue_size >= @player.total_research_queue_size
			render_success(:player => @player.to_hash(:techs), :info => I18n.t('research_error.research_queue_full'))
			return
		end

		tech = @player.technologies.find(:type => params[:tech_type].to_i).first

		if tech.nil?
			tech = Technology.create :type => params[:tech_type].to_i, :level => 0, :player_id => @player.id
		end

		if tech.level >= tech.max_level
			render_error(Error::NORMAL, I18n.t('research_error.reached_max_level')) and return
		end

		unless tech.research_finished?
			render_success(:player => @player.to_hash(:techs), :info => I18n.t('research_error.research_not_complete'))
			return
		end
		
		if @player.spend!(tech.next_level[:cost])
			time_reduce = 0
			# 判断是否触发神灵效果
			if @player.curr_god && @player.curr_god.type == God.hashes[:intelligence]
				time_reduce = @player.trigger_god_effect
			end

			# 判断科技的影响
			time_reduce += @player.tech_research_inc

			b_id = if params[:building_id].nil? || params[:building_id] <= 0
				@player.village.buildings.find(:type => Building.hashes[:workshop]).ids.first
			else
				params[:building_id]
			end

			tech.research!(b_id, time_reduce)

			render_success(:player => @player.to_hash(:techs, :resources))
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_res'))
		end
	end

	def speed_up
		tech_type = params[:tech_type].to_i

		if not tech_type.in?(Technology.types)
			render_error(Error::NORMAL, "INVALID_TECH_TYPE") and return
		end

		tech = @player.technologies.find(:type => tech_type).first

		if tech.nil?
			tech = Technology.create :type => params[:tech_type].to_i, :level => 0, :player_id => @player.id
		end

		if @player.spend!(tech.speed_up_cost)
			tech.speed_up!
			@player.load!
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gems')) and return
		end

		render :json => {
			:message => Error.success_message,
			:player => @player.to_hash(:techs, :village)
		}

	end

	def complete
		render :json => {
			:message => Error.success_message,
			:player => @player.to_hash(:techs, :village)
		}
	end


end






