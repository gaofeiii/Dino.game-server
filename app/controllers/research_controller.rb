class ResearchController < ApplicationController

	before_filter :validate_player

	def research
		if @player.curr_action_queue_size >= @player.action_queue_size
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::TYPES[:normal],
				:error => Error.format_message("BUILDING_QUEUE_IS_FULL")
			} and return
		end
		
		tech = @player.technologies.find(:type => params[:tech_type].to_i).first

		if tech.nil?
			tech = Technology.create :type => params[:tech_type].to_i, :level => 0, :player_id => @player.id
		end
		tech.research!
		data = {:message => Error.success_message, :player => @player.to_hash(:all)}
		render :json => data
	end
end
