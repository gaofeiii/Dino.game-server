class GuideController < ApplicationController

	before_filter :validate_player

	def complete
		q_index = params[:index].to_i
		@player.guide_info[q_index].check!
		data = if @player.guide_info[q_index].finished?
			# TODO: @player.receive_reward()
			@player.guide_info[q_index].rewarded = true
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
