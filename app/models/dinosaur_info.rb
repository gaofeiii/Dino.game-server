class DinosaurInfo

	@@dinosaurs = Hash.new
	@@dinosaur_exps = Hash.new

	class << self

		def all
			@@dinosaurs.blank? ? load! : @@dinosaurs
			@@dinosaurs
		end

		def experience
			@@dinosaur_exps
		end

		def load!
			@@dinosaurs.clear
			@@dinosaur_exps.clear
			book = Excelx.new "#{Rails.root}/const/game_numerics/dinosaurs.xlsx"

			# Reading experiece
			book.default_sheet = 'experience'

			2.upto(book.last_row) do |i|
				level = book.cell(i, "A").to_i
				exp = book.cell(i, 'B').to_i
				@@dinosaur_exps[level] = exp
			end


			# Reading properties
			book.default_sheet = 'dinosaurs'

			2.upto(book.last_row).each do |i|
				type = book.cell(i, 'A').to_i
				name = book.cell(i, 'C').downcase
				hp = book.cell(i, 'E').to_i
				attack = book.cell(i, 'F').to_i
				defense = book.cell(i, 'G').to_i
				agility = book.cell(i, 'H').to_i
				hp_inc = book.cell(i, 'I').to_i
				attack_inc = book.cell(i, 'J').to_f
				defense_inc = book.cell(i, 'K').to_f
				agility_inc = book.cell(i, 'L').to_f
				hatching_time = book.cell(i, 'M').to_i
				unlock_level = book.cell(i, 'N').to_i
				mature_level = book.cell(i, 'O').to_i
				favor_food = book.cell(i, 'P').to_i
				hunger_time = book.cell(i,'Q').to_i
				@@dinosaurs[type] = {
					:dinosaur_type => type,
					:name => name,
					:property => {
						:hp => hp,
						:attack => attack,
						:defense => defense,
						:agility => agility,
						:hatching_time => hatching_time,
						:unlock_level => unlock_level,
						:mature_level => mature_level,
						:favor_food => favor_food,
						:hunger_time => hunger_time
					},
					:enhance_property => {
						:attack_inc => attack_inc,
						:defense_inc => defense_inc,
						:agility_inc => agility_inc,
						:hp_inc => hp_inc,
					},
					:exp => @@dinosaur_exps
				}
			end
			@@dinosaurs
		end

		alias :reload! :load!


	end


end