# encoding: utf-8
puts "--- Reading items const ---"

module ItemsConst
	module ClassMethods
		@@const = Hash.new

		CATEGORIES = {
			:egg => 1,
			:food => 2,
			:scroll => 3,
			:vip => 4,
			:protection => 5,
			:lottery => 6
		}

		def const
			if @@const.blank?
				load_const!
			end
			@@const
		end

		def categories
			CATEGORIES
		end

		def load_const!
			@@const.clear

			book = Excelx.new("#{Rails.root}/const/items.xlsx")

			book.default_sheet = "dino_egg"
			2.upto(book.last_row) do |i|
				type = book.cell(i, 'a').to_i
				@@const[CATEGORIES[:egg]] ||= {}
				@@const[CATEGORIES[:egg]][type] ||= {:type => type}
			end

			book.default_sheet = 'food'
			2.upto(book.last_row) do |i|
				type = book.cell(i, 'a').to_i
				@@const[CATEGORIES[:food]] ||= {}
				@@const[CATEGORIES[:food]][type] = {:type => type}
			end

			book.default_sheet = 'scroll'
			2.upto(book.last_row) do |i|
				type = book.cell(i, 'a').to_i
				effect_val = book.cell(i, 'c').to_f
				@@const[CATEGORIES[:scroll]] ||= {}
				@@const[CATEGORIES[:scroll]][type] = {:type => type, :effect_value => effect_val}
			end

			book.default_sheet = 'vip'
			2.upto(book.last_row) do |i|
				type = book.cell(i, 'a').to_i
				@@const[CATEGORIES[:vip]] ||= {}
				@@const[CATEGORIES[:vip]][type] = {:type => type}
			end

			book.default_sheet = 'protection'
			2.upto(book.last_row) do |i|
				type = book.cell(i, 'a').to_i
				@@const[CATEGORIES[:protection]] ||= {}
				@@const[CATEGORIES[:protection]][type] = {:type => type}
			end

			book.default_sheet = 'ticket'
			2.upto(book.last_row) do |i|
				type = book.cell(i, 'a').to_i
				@@const[CATEGORIES[:lottery]] ||= {}
				@@const[CATEGORIES[:lottery]][type] = {:type => type}
			end
		end
	end
	
	module InstanceMethods
		
		def info
			self.class.const[item_category][item_type]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end