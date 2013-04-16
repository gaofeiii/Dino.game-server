class DailyQuestController < ApplicationController
	before_filter :validate_player, :only => [:refresh, :get_reward]

	def refresh
		@player.update_daily_quest_status!
		@player.reset_daily_quest!

		# Check beginner guide
		if @player.has_beginner_guide?
			@player.cache_beginner_data(:has_opened_quests => true)
		end

		render_success(:player => @player.to_hash(:daily_quest))
	end

	def get_reward
		quest = @player.find_task_by_index(params[:quest_id].to_i)

		if quest && quest.get_reward
			quest.set_rewarded(true)
			render_success(:player => @player.load!.to_hash(:daily_quest))
		else
			render_error(Error::NORMAL, I18n.t('quests_error.not_finished_yet'))
		end

	end

end
