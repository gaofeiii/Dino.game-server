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
		lock_key = @player.key[:quest][params[:quest_id]]

		if Ohm.redis.setnx(lock_key, 0)
			quest = @player.find_task_by_index(params[:quest_id].to_i)

			if quest && quest.get_reward
				quest.set_rewarded(true)
				Ohm.redis.del(lock_key)
				render_success(:player => @player.load!.to_hash(:daily_quest))
			else
				Ohm.redis.del(lock_key)
				render_error(Error::NORMAL, I18n.t('quests_error.not_finished_yet'))
			end

		else
			render_success(:player => @player.to_hash(:daily_quest))
		end

	end

end
