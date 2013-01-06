module DinosaursConst
	module ClassMethods
		@@dinosaurs_const = Hash.new
		@@dinosaurs_exp = Hash.new

		%w(const exp).each do |name|
			define_method(name) do
				if eval("@@dinosaurs_#{name}").blank?
					reload!
				end
				eval("@@dinosaurs_#{name}")
			end
		end

		alias info const

		def reload!
			@@dinosaurs_const.clear
			@@dinosaurs_exp.clear

			book = Excelx.new "#{Rails.root}/const/dinosaurs.xlsx"

			# ===Reading experiece===
			book.default_sheet = 'experience'

			2.upto(52) do |i|
				level = book.cell(i, "A").to_i
				exp = book.cell(i, 'B').to_i
				@@dinosaurs_exp[level] = exp
			end


			# ===Reading properties===
			book.default_sheet = 'dinosaurs_avai'

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
				skill_type = book.cell(i, 'D').to_i
				@@dinosaurs_const[type] = {
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
					:exp => @@dinosaurs_exp,
					:skill_type => skill_type
				}
			end
			@@dinosaurs_const
		end


	end
	
	module InstanceMethods
		
		def info
			self.class.info[type]
		end

		def next_level_exp
			exp = info[:exp][level + 1]
			exp.nil? ? 99999999 : exp
		end

		def key_name
			info[:name].to_sym
		end

		def property
			info[:property]
		end

		def favor_food
			property[:favor_food]
		end

		def hunger_time
			property[:hunger_time]
		end

		def is_my_favorite_food(food_type)
			property[:favor_food] == food_type
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end