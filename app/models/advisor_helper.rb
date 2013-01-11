module AdvisorHelper
	module ClassMethods
		@@advisor_const = Hash.new

		def const
			if @@advisor_const.blank?
				load_const!
			end
			@@advisor_const
		end
		
		def load_const!
			puts "--- Loading advisors const ---"
			@@advisor_const.clear

			book = Excelx.new "#{Rails.root}/const/advisors.xlsx"

			2.upto(book.last_row) do |i|
				lvl = book.cell(i, 'a').to_i
				price = book.cell(i, 'B').to_i
				inc_damage = book.cell(i, 'C').to_f
				inc_produce = book.cell(i, 'd').to_f
				inc_research = book.cell(i, 'E').to_f
				inc_business = book.cell(i, 'f').to_f

				@@advisor_const[lvl] = {
					:level => lvl,
					:price_per_day => price,
					:inc_damage => inc_damage,
					:inc_produce => inc_produce,
					:inc_research => inc_research,
					:inc_business => inc_business
				}
			end
		end

		def hire_price(level, days)
			self.const[level][:price_per_day] * days
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end