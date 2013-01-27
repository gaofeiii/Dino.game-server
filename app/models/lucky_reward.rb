# encoding: utf-8
class LuckyReward
	MAX_RATE = 1000001
	@@const = {
		1 => {},
		2 => {},
		3 => {}
	}

	# Class methods:
	class << self

		def const(type)
			if @@const[type].blank?
				load_const!
			end
			@@const[type]
		end

		def load_const!
			@@const = {
				1 => {},
				2 => {},
				3 => {}
			}
			book = Excelx.new "#{Rails.root}/const/抽奖.xlsx"

			@@const[1] = read_sheet(book, '奖券1')
			@@const[2] = read_sheet(book, '奖券2')
			@@const[3] = read_sheet(book, '奖券3')

			@@const
		end

		def read_sheet(book, sheet_name)
			const_value = {}
			book.default_sheet = sheet_name

			2.upto(book.last_row) do |i|
				cat = book.cell(i, 'c')
				type = book.cell(i, 'd').to_i
				num = book.cell(i, 'f').to_f

				min_odds = book.cell(i, 'i').to_i
				max_odds = book.cell(i, 'j').to_i

				rwd = {}
				case cat
				when 'wood'
					rwd = {
						:category => 1,
						:num => num.to_f
					}
				when 'stone'
					rwd = {
						:category => 2,
						:num => num.to_f
					}
				when 'gold'
					rwd = {
						:category => 3,
						:num => num.to_f
					}
				when 'food'
					rwd = {
						:category => 4,
						:type => type,
						:count => num.to_i
					}
				when 'egg'
					rwd = {
						:category => 5,
						:type => type,
						:count => num.to_i
					}
				when 'scroll'
					rwd = {
						:category => 6,
						:type => type,
						:count => num.to_i
					}
				end

				if !rwd.blank?
					const_value[min_odds...max_odds] = rwd
				end
			end
			const_value
		end # End of defining method: load_const!

		def rand_one(item_type)
			num = rand(1..MAX_RATE)

			const(item_type.to_i).each do |key, val|
				if num.in?(key)
					return val
				end
			end
		end
	end
end