class GuideController < ApplicationController

	before_filter :validate_player

	def complete
		q_index = params[:index].to_i
		# @player.refresh_village_status
		# @player.guide_info.check_finished(q_index)

		# @player.save if q_index > 0 && @player.guide_info[q_index].finished?
		guide = @player.find_beginner_guide_by_index(q_index)
		guide.check
		render_success(:player => @player.to_hash(:beginning_guide))
	end

	def get_reward
		q_index = params[:index].to_i

		# @player.guide_info.check_finished(q_index)
		
		# ret = false

		# if @player.guide_info[q_index].finished?
		# 	@player.get_reward(Reward.new(Player.beginning_guide_reward(q_index)))
		# 	@player.guide_info[q_index].rewarded = true
		# 	ret = true
		# end

		# if @player.guide_info.finish_all?
		# 	@player.beginning_guide_finished = true
		# 	ret = true
		# end

		# @player.save if ret
		guide = @player.find_beginner_guide_by_index(q_index)
		
		if guide.check
			@player.get_reward(guide.reward)
			guide.update :rewarded => true
		end

		if guide.is_last?
			@player.set :beginning_guide_finished, 1
		end

		render_success(:player => @player.to_hash(:beginning_guide))
	end
end
