class GodController < ApplicationController
	before_filter :validate_player, :only => [:worship_gods, :cancel_worship_gods]

	# 供奉神灵
	def worship_gods
		if not params[:god_type].in?(God::TYPE.values)
			render_error(Error.types[:normal], "Invalid god type") and return
		end

		cost = {:wood => 1000, :stone => 1000, :gold_coin => 100}
		if @player.spend!(cost)
			God.create(:type => params[:god_type], :level => 1, :start_time => Time.now.to_i, :player_id => @player.id)
			if !@player.beginning_guide_finished && !@player.guide_cache['has_worshiped']
				cache = @player.guide_cache.merge(:has_worshiped => true)
				@player.set :guide_cache, cache
			end
			render_success(:player => @player.to_hash(:resources, :god))
		else
			render_error(Error.types[:normal], "Not enough resources")
		end
	end

	# 取消供奉神灵
	def cancel_worship_gods
		god = @player.gods.find(:type => params[:god_type]).first

		if god.nil? || !params[:god_type].in?(God::TYPE.keys)
			render_error(Error.types[:normal], "Invalid god type") and return
		end

		god.delete
		render_success(:player => @player.to_hash(:resources, :god))
	end
end

