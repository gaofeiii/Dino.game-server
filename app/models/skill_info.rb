class SkillInfo
	
	class << self

		@@skills = Hash.new

		def all
			if @@skills.blank?
				load!
			end
			@@skills
		end

		def load!
			@@skills.clear
			book = Excelx.new "#{Rails.root}/const/game_numerics/dinosaurs.xlsx"
			book.default_sheet = 'skills'

			2.upto(book.last_row) do |i|
				type = book.cell(i, 'A').to_i
				name = book.cell(i, 'B').to_s
				trig_chan = book.cell(i, 'I').to_f

				@@skills[type] = {
					:name => name,
					:trigger_chance => trig_chan
				}
			end
			
		end

		alias reload! load!

	end
end