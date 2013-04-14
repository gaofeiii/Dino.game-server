module GoldMineConst
	module ClassMethods
		@@const = {}
		@@upgrade_cost = {}
		
		def gold_output(lvl = 1)
			const[lvl][:gold_output]
		end

		def load_const!
			puts "--- Reading GoldMine const ---"
			@@const.clear
			@@upgrade_cost = {
				1 => {},
				2 => {}
			}

			book = Roo::Excelx.new "#{Rails.root}/const/gold_mines.xlsx"
			book.default_sheet = 'normal'

			2.upto(book.last_row) do |i|
				level = book.cell(i, 'A').to_i
				output = book.cell(i, 'B').to_i
				creeps_type = book.cell(i, 'C').to_i
				wood = book.cell(i, 'D').to_i
				stone = book.cell(i, 'E').to_i

				@@const[level] = {
					:gold_output => output, 
					:creeps_types => creeps_type,
				}

				@@upgrade_cost[1][level] = {
					:wood => wood,
					:stone => stone,
					:output => output
				}
			end

			book.default_sheet = 'league'

			2.upto(book.last_row) do |i|
				level = book.cell(i, 'A').to_i
				output = book.cell(i, 'B').to_i
				wood = book.cell(i, 'D').to_i
				stone = book.cell(i, 'E').to_i

				@@upgrade_cost[2][level] = {
					:wood => wood,
					:stone => stone,
					:output => output
				}
			end
		end

		def const
			if @@const.blank?
				load_const!
			end
			@@const
		end

		def upgrade_cost
			if @@upgrade_cost.blank?
				load_const!
			end

			@@upgrade_cost
		end

	end
	
	module InstanceMethods
		
		def next_level_cost
			cost = self.class.upgrade_cost[type][level + 1]
			if cost
				cost.slice(:wood, :stone)
			else
				{
					:wood => 99999999, :stone => 99999999
				}
			end
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end