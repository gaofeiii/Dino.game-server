module LeagueWar
	WAR_TIME = 15.minutes.to_i
	WAR_INTERVAL = 1.hour.to_i

	def key
		@key ||= Nest.new("LeagueWar")
	end

	def begin_time
		Time.now.beginning_of_hour.to_i
	end

	def end_time
		begin_time + WAR_TIME
	end

	def next_begin_time
		begin_time + WAR_INTERVAL
	end

	def time_left
		next_begin_time - ::Time.now.to_i
	end

	module_function :begin_time, :end_time, :next_begin_time, :time_left

	# 部落战时间改为每小时一次，整点开始，持续15分钟
	def in_period_of_fight?
		Time.now.to_i.in?(begin_time..end_time)
	end

	def can_fight_danger_village?
		not in_period_of_fight?
	end

	# 整点1刻进行此操作
	def calc_battle_result
		return false if Time.now.to_i < calc_time

		GoldMine.find(:type => 2).each do |gold_mine|
			winner_league = League[gold_mine.winner_league_id]
			if winner_league
				winner_league.winned_mines.add(gold_mine)
			end
		end

		set_next_calc_time
	end

	# 整点进行重置金矿的操作
	def reset_gold_mine
		return false if Time.now.to_i < reset_time

		League.all.ids.each do |league_id|
			league = League.new :id => league_id
			Ohm.redis.del league.winned_mines.key
		end

		LeagueMemberShip.all.ids.each do |membership_id|
			memebership = LeagueMemberShip.new :id => membership_id
			memebership.set :receive_gold_count, 0
		end

		set_reset_time
	end

	def set_calc_result_this_period
		time = end_time
		Ohm.redis.set(key[:calc_time], time)
	end

	def set_next_calc_time
		Ohm.redis.set(key[:calc_time], end_time + WAR_INTERVAL)
	end

	def set_reset_time
		time = begin_time + WAR_INTERVAL
		Ohm.redis.set(key[:reset_time], time)
	end

	def calc_time
		Ohm.redis.get(key[:calc_time]).to_i
	end

	def reset_time
		Ohm.redis.get(key[:reset_time]).to_i
	end

	def refresh_league_gold_coins
		League.all.each do |league|
			league.calc_harvest_gold!
		end
	end

	module_function :set_calc_result_this_period, :set_next_calc_time, :set_reset_time, :calc_time, :reset_time, :refresh_league_gold_coins

	def start!
		set_calc_result_this_period
		set_reset_time
	end

	def perform!
		calc_battle_result
		reset_gold_mine
		refresh_league_gold_coins
	end



	module_function(
		:key, 
		:in_period_of_fight?, 
		:can_fight_danger_village?, 
		:calc_battle_result, 
		:reset_gold_mine,
		:start!,
		:perform!
	)

end