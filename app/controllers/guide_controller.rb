class GuideController < ApplicationController

	before_filter :validate_player

	def complete
		q_index = params[:index].to_i
		@player.guide_info.check_finished(q_index)

		data = if @player.guide_info[q_index].finished?
			@player.save
			{
				:message => Error.success_message,
				:player => @player.to_hash(:beginning_guide)
			}
		else
			{
				:message => Error.failed_message,
				:error_type => Error::TYPES[:normal],
				:error => "QUEST_NOT_FINISHED"
			}
		end
		render :json => data
	end

	def get_reward
		q_index = params[:index].to_i
		@player.guide_info.check_finished(q_index)

		data = if @player.guide_info[q_index].finished?
			if @player.receive_guide_reward!(Player.beginning_guide_reward(q_index))
				@player.guide_info[q_index].rewarded = true
			end

			if @player.guide_info.finish_all?
				@player.beginning_guide_finished = true
			end
			@player.save
			{
				:message => Error.success_message,
				:player => @player.to_hash(:all)
			}
		else
			{
				:message => Error.failed_message,
				:error_type => Error::TYPES[:normal],
				:error => "QUEST_NOT_FINISHED"
			}
		end
		render :json => data
	end
end
