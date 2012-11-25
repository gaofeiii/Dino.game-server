class GuideController < ApplicationController

	before_filter :validate_player

	def complete
		q_index = params[:index].to_i
		@player.guide_info[q_index].check!
		data = if @player.guide_info[q_index].finished?
			# TODO: @player.receive_reward()
			@player.guide_info[q_index].rewarded = true
			if @player.guide_info[BegginingGuide::LAST_GUIDE_INDEX].over?
				@player.beginning_guide_finished = true
			end
			@player.save
			{
				:message => "SUCCESS",
				:player => player.to_hash(:all)
			}
		else
			{
				:message => "FAILED",
				:error_type => 1,
				:error => "QUEST_NOT_FINISHED"
			}
		end
		render :json => data
	end
end
