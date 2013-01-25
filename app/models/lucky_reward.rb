# encoding: utf-8
class LuckyReward
	MAX_RATE = 1000001
	@@const = Hash.new

	# Class methods:
	class << self

		def const
			if @@const.blank?
				load_const!
			end
			@@const
		end

		def load_const!
			book = Excelx.new "#{Rails.root}/const/抽奖.xlsx"

			book.default_sheet = 'data'
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
						:res_type => 1,
						:num => num.to_f
					}
				when 'stone'
					rwd = {
						:category => 2,
						:res_type => 2,
						:num => num.to_f
					}
				when 'gold'
					rwd = {
						:category => 3,
						:res_type => 3,
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
					@@const[min_odds...max_odds] = rwd
				end
			end
		end

		def get_one
			num = rand(1..MAX_RATE)

			const.each do |key, val|
				if num.in?(key)
					return val
				end
			end
		end
	end
end