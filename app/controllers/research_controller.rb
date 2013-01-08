class ResearchController < ApplicationController

	before_filter :validate_player

	def research
		if @player.curr_research_queue_size >= @player.total_research_queue_size
			render_error(Error::NORMAL, "research queue is full") and return
		end

		tech = @player.technologies.find(:type => params[:tech_type].to_i).first

		if tech.nil?
			tech = Technology.create :type => params[:tech_type].to_i, :level => 0, :player_id => @player.id
		end

		unless tech.research_finished?
			render_error(Error::NORMAL, "Researching not complete") and return
		end
		
		if @player.spend!(tech.next_level[:cost])
			tech.research!(params[:building_id])
			if !@player.beginning_guide_finished && !@player.guide_cache['has_researched']
				cache = @player.guide_cache.merge(:has_researched => true)
				@player.set :guide_cache, cache
			end
			render_success(:player => @player.to_hash(:techs, :resources))
		else
			render_error(Error::NORMAL, "NOT_ENOUGH_RESOURCES")
		end
	end

	def speed_up
		tech_type = params[:tech_type].to_i

		if not tech_type.in?(Technology.types)
			render_error(Error::NORMAL, "Wrong type of technology") and return
		end

		tech = @player.technologies.find(:type => tech_type).first

		if tech.nil?
			tech = Technology.create :type => params[:tech_type].to_i, :level => 0, :player_id => @player.id
		end

		p "--- gem: #{tech.speed_up_cost}"

		if @player.spend!(tech.speed_up_cost)
			tech.speed_up!
		else
			render_error(Error::NORMAL, "Not enough gems") and return
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






