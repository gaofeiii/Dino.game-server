module PlayerGoldHelper

	# 当前玩家可以拥有的金矿数量
	def curr_goldmine_size
		return 5 if level <= 10
		return 5 + (level - 10) / 2
	end

	# 收获金矿
	def harvest_gold_mines
		mines = self.gold_mines
		return false if mines.empty?

		all_total = mines.map do |mine|
			delta_t = (Time.now.to_i - mine.update_gold_time) / 3600.0
			harvest_gold_count = (delta_t * mine.output).to_i

			# self.receive!(:gold => harvest_gold_count) if harvest_gold_count > 0
			mine.set :update_gold_time, Time.now.to_i
			harvest_gold_count.to_i
		end

		total = (all_total.sum * (1 + tech_gold_inc)).to_i

		if total > 0
			self.receive!(:gold => total)
			Mail.create_goldmine_total_harvest_mail :receiver_id 		=> self.id,
																							:receiver_name 	=> self.nickname,
																							:locale 				=> self.locale,
																							:count 					=> total
		end
	end

	def harvest_gold_mines_manual
		mines = self.gold_mines
		return 0 if mines.empty?

		all_gold = mines.map do |mine|
			curr_time = Time.now.to_i

			delta_t = (curr_time - mine.update_gold_time) / 3600.0
			gold_count = (delta_t * mine.output).to_i

			# mine.set :update_gold_time, curr_time if gold_count > 0
			gold_count
		end

		total = (all_gold.sum * (1 + tech_gold_inc)).to_i

		self.receive!(:gold => total) if total > 0
		total
	end

end # End of 'module PlayerGoldHelper'