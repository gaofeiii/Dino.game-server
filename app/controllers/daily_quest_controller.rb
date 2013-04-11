class DailyQuestController < ApplicationController
	before_filter :validate_player, :only => [:refresh, :get_reward]

	def refresh
		@player.update_daily_quest_status!
		@player.reset_daily_quest!

		# refresh_daily_quest
		if !@player.beginning_guide_finished && @player.guide_cache[:refresh_daily_quest].nil?
			cache = @player.guide_cache.merge(:refresh_daily_quest => true)
			@player.set :guide_cache, cache.to_json
		end

		if @player.has_beginner_guide?
			@player.cache_beginner_data(:has_opened_quests => true)
		end

		render_success(:player => @player.to_hash(:daily_quest))
	end

	def get_reward
		# quest = @player.find_quest_by_index(params[:quest_id])

		# if quest.nil?
		# 	quest = @player.curr_bill_quest

		# 	if quest
		# 		if @player.get_bill_reward
		# 		else
		# 			render_error(Error::NORMAL, I18n.t('quests_error.not_finished_yet')) and return
		# 		end
		# 	end
		# 	render_success(:player => @player.to_hash(:daily_quest))
		# else
		# 	if @player.set_rewarded(params[:quest_id])
		# 		@player.set :daily_quest, @player.daily_quest.to_json
		# 		render_success(:player => @player.to_hash(:daily_quest))
		# 	else
		# 		render_error(Error::NORMAL, I18n.t('quests_error.not_finished_yet'))
		# 	end
		# end

		quest = @player.find_task_by_index(params[:quest_id].to_i)

		if quest && quest.get_reward
			render_success(:player => @player.to_hash(:daily_quest))
		else
			render_error(Error::NORMAL, I18n.t('quests_error.not_finished_yet'))
		end

	end

end
