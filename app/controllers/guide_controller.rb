class GuideController < ApplicationController

	before_filter :validate_player

	def complete
		q_index = params[:index].to_i

		guide = @player.find_beginner_guide_by_index(q_index)

		if guide
			guide.check
		end

		render_success(:player => @player.to_hash(:beginning_guide))
	end

	def get_reward
		q_index = params[:index].to_i

		guide = @player.find_beginner_guide_by_index(q_index)
		
		if guide
			if guide.check
				@player.get_reward(guide.reward)
				guide.update :rewarded => true
			end

			if guide.is_last?
				@player.set :beginning_guide_finished, 1
			end
		end

		render_success(:player => @player.to_hash(:beginning_guide))
	end
end
