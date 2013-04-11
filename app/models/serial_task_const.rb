module SerialTaskConst

	module ClassMethods
		@@const = {}

		def load_const!
			@@const.clear

			book = Roo::Excelx.new "#{Rails.root}/const/newquest.xlsx"

			book.default_sheet = 'serial'

			3.upto(book.last_row) do |i|
				num = book.cell(i, 'A').to_i
				wood = book.cell(i, 'd').to_i
				stone = book.cell(i, 'd').to_i
				gold = book.cell(i, 'e').to_i
				gems = book.cell(i, 'f').to_i
				item_cat = book.cell(i, 'g').to_i
				item_type = book.cell(i, 'h').to_i
				item_count = book.cell(i, 'i').to_i
				quality = book.cell(i, 'j').to_i
				exp = book.cell(i, 'k').to_i
				forward_num = book.cell(i, 'l').to_i
				total_step = book.cell(i, 'm').to_i
				en_desc = book.cell(i, 'n')
				cn_desc = book.cell(i, 'o')

				@@const[num] = {
					:index => num,
					:reward => {
						:gold_coin => gold,
						:item => {
							:item_cat => item_cat,
							:item_type => item_type,
							:item_count => item_count,
							:quality => quality,
							:xp => exp
						}
					},
					:total_steps => total_step,
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

		def forward_index
			info[:forward_index]
		end

		def total_steps
			info[:total_steps]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end