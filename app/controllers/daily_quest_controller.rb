class DailyQuestController < ApplicationController
	before_filter :validate_player, :only => [:refresh, :get_reward]

	def refresh
		@player.update_daily_quest!
		render_success(:player => @player.to_hash(:daily_quest))
	end

	def get_reward
		
		render_success(:player => @player.to_hash(:daily_quest))
	end
end
