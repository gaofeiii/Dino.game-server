class GodController < ApplicationController
	before_filter :validate_player, :only => [:worship_gods, :cancel_worship_gods, :query_god]

	# 供奉神灵
	def worship_gods
		if not params[:god_type].in?(God.hashes.values)
			render_error(Error::NORMAL, "INVALID_GOD_TYPE") and return
		end

		god = @player.curr_god
		cost = {:wood => 1000, :stone => 1000, :gold_coin => 1000}

		if @player.spend!(cost)
			if god
				god.update :type => params[:god_type], :start_time => Time.now.to_i, :end_time => Time.now.to_i + 1.day.to_i
			else
				God.create(:type => params[:god_type], :level => 1, :start_time => Time.now.to_i, :player_id => @player.id, :end_time => Time.now.to_i + 1.day.to_i)
			end
		end

		if @player.has_beginner_guide?
			@player.cache_beginner_data(:has_worshipped_god => true)
		end
		
		render_success(:player => @player.to_hash(:resources, :god))
	end

	def query_god
		render_success(:player => @player.to_hash(:god))
	end

	# 取消供奉神灵
	def cancel_worship_gods
		god = @player.gods.find(:type => params[:god_type]).first

		if god.nil? || !params[:god_type].in?(God::TYPE.keys)
			render_error(Error::NORMAL, "INVALID_GOD_TYPE") and return
		end

		god.delete
		render_success(:player => @player.to_hash(:resources, :god))
	end
end

