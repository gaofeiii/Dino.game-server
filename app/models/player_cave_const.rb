module PlayerCaveConst
	TOTAL_COUNT = 3
	
	module ClassMethods
		@@caves_const = {}

		def caves_const
			if @@caves_const.blank?
				load_caves_const!
			end

			@@caves_const
		end

		def load_caves_const!
			@@caves_const.clear

			book = Roo::Excelx.new("#{Rails.root}/const/cave.xlsx")

			book.default_sheet = 'cave'

			3.upto(book.last_row) do |i|
				idx = book.cell(i, 'A').to_i

				mons_level = book.cell(i, 'C').to_i
				mons_num = book.cell(i, 'D').to_i

				gold = book.cell(i, 'E').to_i
				wood = book.cell(i, 'F').to_i
				stone = book.cell(i, 'G').to_i
				item_cate = book.cell(i, 'H').to_i
				item_type = book.cell(i, 'I').to_i
				item_count = book.cell(i, 'J').to_i
				item_quality = book.cell(i, 'K').to_i

				star_1_chance = book.cell(i, 'M').to_f
				star_2_chance = book.cell(i, 'N').to_f
				star_3_chance = book.cell(i, 'O').to_f

				reward = {}
				reward[:gold_coin] = gold if gold > 0
				reward[:wood] = wood if wood > 0
				reward[:stone] = stone if stone > 0

				reward[:item_cat] = item_cate if item_cate > 0
				reward[:item_type] = item_type if item_type > 0
				reward[:item_count] = item_count if item_count > 0
				reward[:quality] = item_quality if item_quality > 0

				# TODO:

				star_round = {
					1 => book.cell(i, 'Q').to_i,
					2 => book.cell(i, 'R').to_i,
					3 => book.cell(i, 'S').to_i
				}

				round_stars = {}
				star_round.each{ |k, v| round_stars[v] = k }

				@@caves_const[idx] = {
					:index => idx,
					:monster_level => mons_level,
					:monster_num => mons_num,
					:reward => reward,
					:star_round => star_round,
					:round_stars => round_stars,
					:star_1_chance => star_1_chance,
					:star_2_chance => star_2_chance,
					:star_3_chance => star_3_chance
				}

			end
		end

		def cave_rounds_stars(rounds_count)
			return 0 if rounds_count <= 0

			return case rounds_count
			when 1..3
				3
			when 4
				2
			else
				1
			end
		end

		def all_star_rewards
			rewards = {}
			caves_const.each do |idx, info|
				rewards[idx] = {
					1 => {:wood => idx * 10, :stone => idx * 10},
					2 => {:wood => idx * 15, :stone => idx * 15},
					3 => info[:reward]
				}
			end
			rewards
		end

	end
	
	module InstanceMethods
		
		def info
			self.class.caves_const[index]
		end

		def star_1_chance
			info[:star_1_chance]
		end

		def star_2_chance
			info[:star_2_chance]
		end

		def star_3_chance
			info[:star_3_chance]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end