module LeagueWar

	def in_period_of_fight?(time = Time.now.to_i)
		begin_day = Time.now.beginning_of_day.to_i
		period_1 = begin_day..(begin_day + 30.minutes.to_i)
		period_2 = (begin_day + 8)..(begin_day + 8 + 30.minutes.to_i)
		period_3 = (begin_day + 16)..(begin_day + 16 + 30.minutes.to_i)

		time.in?(period_1) && time.in?(period_2) && time.in?(period_3)
		false
	end

	def can_fight_danger_village?(time = Time.now.to_i)
		# in_period_of_fight?(time)
		false
	end

	module_function :in_period_of_fight?, :can_fight_danger_village?

end