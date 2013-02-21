module LeagueConst
	module ClassMethods

		@@const = Hash.new

		def const
			if @@const.blank?
				load_const!
			end
			@@const
		end

		def load_const!
			@@const.clear

			book = Excelx.new("#{Rails.root}/const/league_const.xlsx")
			book.default_sheet = 'league'

			4.upto(book.last_row) do |i|
				level = book.cell(i, 'b').to_i
				next_lvl_xp = book.cell(i, 'c').to_i
				max_mine = book.cell(i, 'D').to_i
				salary = book.cell(i, 'e').to_f
				dkp_salary_cost = book.cell(i, 'f').to_i
				dkp_battle_inc = book.cell(i, 'g').to_i
				exp_battle_inc = book.cell(i, 'h').to_i
				dkp_wood_unit = book.cell(i, 'i').to_i
				dkp_stone_unit = book.cell(i, 'j').to_i
				dkp_donate_inc = book.cell(i, 'k').to_i
				exp_donate_inc = book.cell(i, 'l').to_i
				
				@@const[level] = {
					:level => level,
					:next_level_xp => next_lvl_xp,
					:max_mine => max_mine,
					:salary_factor => salary,
					:dkp_salary_cost => dkp_salary_cost,
					:dkp_battle_inc => dkp_battle_inc,
					:exp_battle_inc => exp_battle_inc,
					:dkp_wood_unit => dkp_wood_unit,
					:dkp_stone_unit => dkp_stone_unit,
					:dkp_donate_inc => dkp_donate_inc,
					:exp_donate_inc => exp_donate_inc
				}
			end
		end
		
		def positions
			{
				:president => 10,
				:vice_president => 9,
				:member => 1
			}
		end
	end
	
	module InstanceMethods
		
		def info
			self.class.const[level]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end