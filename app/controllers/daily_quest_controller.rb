class DailyQuestController < ApplicationController
	before_filter :validate_player, :only => [:refresh, :get_reward]

	def refresh
		@player.update_daily_quest_status!
		@player.reset_daily_quest!
		render_success(:player => @player.to_hash(:daily_quest))
	end

	def get_reward
		quest = @player.find_quest_by_index(params[:quest_id])

		if quest.nil?
			render_error(Error::NORMAL, "Invalid quest id") and return
		end

		if @player.set_rewarded(params[:quest_id])
			@player.set :daily_quest, @player.daily_quest.to_json
			render_success(:player => @player.to_hash(:daily_quest))
		else
			render_error(Error::NORMAL, I18n.t('quests_error.not_finished_yet'))
		end
		
	end
end
