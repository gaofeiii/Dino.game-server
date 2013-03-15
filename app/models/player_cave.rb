module PlayerCave
	module ClassMethods
		@@cave_const = {}

		def cave_const
			if @@cave_const.blank?
				load_cave_const!
			end
			@@cave_const
		end

		def load_cave_const!
			book = Roo::Excelx.new("#{Rails.root}/const/cave.xlsx")

			book.default_sheet = "cave"

			3.upto(book.last_row) do |i|
				
			end
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end