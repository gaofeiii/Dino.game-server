module GoldMineConst
	module ClassMethods
		@@const = Hash.new
		
		def gold_output(lvl = 1)
			const[lvl][:gold_output]
		end

		def load_const!
			puts "--- Reading GoldMine const ---"
			@@const.clear

			book = Roo::Excelx.new "#{Rails.root}/const/gold_mines.xlsx"
			book.default_sheet = 'normal'

			2.upto(book.last_row) do |i|
				level = book.cell(i, 'A').to_i
				output = book.cell(i, 'B').to_i
				creeps_type = book.cell(i, 'C').to_i

				@@const[level] = {
					:gold_output => output, 
					:creeps_types => creeps_type
				}
			end
		end

		def const
			if @@const.empty?
				load_const!
			end
			@@const
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end