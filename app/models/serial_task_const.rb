module SerialTaskConst

	module ClassMethods
		@@const = {}

		def load_const!
			@@const.clear

			book = Roo::Excelx.new "#{Rails.root}/const/newquest.xlsx"

			book.default_sheet = 'serial'

			3.upto(book.last_row) do |i|
				num = book.cell(i, 'A').to_i
				gold = book.cell(i, 'c').to_i
				item_cat = book.cell(i, 'd').to_i
				item_type = book.cell(i, 'e').to_i
				item_count = book.cell(i, 'f').to_i
				quality = book.cell(i, 'g').to_i
				exp = book.cell(i, 'h').to_i
				forward_num = book.cell(i, 'i').to_i
				en_desc = book.cell(i, 'j')
				cn_desc = book.cell(i, 'k')

				@@const[num] = {
					:index => num,
					:reward => {
						:gold => gold,
						:item => {
							:item_cat => item_cat,
							:item_type => item_type,
							:item_count => item_count,
							:quality => quality,
							:xp => exp
						}
					},
					:forward_index => forward_num,
					:desc => {
						:en => en_desc,
						:cn => cn_desc
					}
				}
			end
		end

		def const
			if @@const.blank?
				load_const!
			end
			@@const
		end

		def all_indices
			@@all_indices ||= const.keys
			@@all_indices
		end
	end
	
	module InstanceMethods
		
		def info
			self.class.const[index]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end