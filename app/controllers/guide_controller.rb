class GuideController < ApplicationController

	before_filter :validate_player

	def complete
		q_index = params[:index].to_i
		@player.refresh_village_status
		@player.guide_info.check_finished(q_index)

		@player.save if q_index > 0 && @player.guide_info[q_index].finished?
		render_success(:player => @player.to_hash(:beginning_guide))
	end

	def get_reward
		q_index = params[:index].to_i

		@player.guide_info.check_finished(q_index)
		

		# data = if @player.guide_info[q_index].finished?
		# 	if @player.receive_guide_reward!(Player.beginning_guide_reward(q_index))
		# 		@player.guide_info[q_index].rewarded = true
		# 	end

		# 	if @player.guide_info.finish_all?
		# 		@player.beginning_guide_finished = true
		# 	end
		# 	@player.save
		# 	{
		# 		:message => Error.success_message,
		# 		:player => @player.to_hash(:resources)
		# 	}
		# else
		# 	{
		# 		# :message => Error.failed_message,
		# 		# :error_type => Error::NORMAL,
		# 		# :error => I18n.t('guide_error.quest_not_finished')
		# 		:message => Error.success_message,
		# 		:player => @player.to_hash(:resources)
		# 	}
		# end
		# render :json => data
		ret = false

		if @player.guide_info[q_index].finished?
			@player.receive_guide_reward!(Player.beginning_guide_reward(q_index))
			@player.guide_info[q_index].rewarded = true
			ret = true
		end

		if @player.guide_info.finish_all?
			@player.beginning_guide_finished = true
			ret = true
		end

		@player.save if ret
		render_success(:player => @player.to_hash(:beginning_guide))
	end
end
