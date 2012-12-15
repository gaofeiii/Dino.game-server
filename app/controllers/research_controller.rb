class ResearchController < ApplicationController

	before_filter :validate_player

	def research
		if @player.curr_research_queue_size >= @player.total_research_queue_size
			render_error(Error.types[:normal], "research queue is full") and return
		end

		tech = @player.technologies.find(:type => params[:tech_type].to_i).first

		if tech.nil?
			tech = Technology.create :type => params[:tech_type].to_i, :level => 0, :player_id => @player.id
		end

		unless tech.research_finished?
			render_error(Error.types[:normal], "Researching not complete") and return
		end
		
		tech.research!(params[:building_id])
		data = {:message => Error.success_message, :player => @player.to_hash(:techs)}
		render :json => data
	end

	def speed_up
		tech_type = params[:tech_type].to_i

		if not tech_type.in?(Technology.types)
			render_error(Error.types[:normal], "Wrong type of technology") and return
		end

		tech = @player.technologies.find(:type => tech_type).first

		if tech.nil?
			tech = Technology.create :type => params[:tech_type].to_i, :level => 0, :player_id => @player.id
		end

		if @player.spend!(tech.speed_up_cost)
			tech.speed_up!
		else
			render_error(Error.types[:normal], "Not enough gems") and return
		end

		render :json => {
			:message => Error.success_message,
			:player => @player.to_hash(:techs)
		}

	end

	def complete
		render :json => {
			:message => Error.success_message,
			:player => @player.to_hash(:techs)
		}
	end


end






