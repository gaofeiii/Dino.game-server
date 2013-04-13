module DinosaursConst
	module ClassMethods
		@@dinosaurs_const = Hash.new
		@@dinosaurs_exp = Hash.new
		@@dinosaurs_training_info = Hash.new

		%w(const exp).each do |name|
			define_method(name) do
				if eval("@@dinosaurs_#{name}").blank?
					reload!
				end
				eval("@@dinosaurs_#{name}")
			end
		end

		alias info const

		def types
			self.const.keys
		end

		def reload!
			@@dinosaurs_const.clear
			@@dinosaurs_exp.clear
			@@dinosaurs_training_info.clear


			book = Roo::Excelx.new "#{Rails.root}/const/dinosaurs.xlsx"

			# ===Reading experiece===
			book.default_sheet = 'experience'

			2.upto(book.last_row) do |i|
				level = book.cell(i, "A").to_i
				exp = book.cell(i, 'B').to_i
				gold_cost = book.cell(i, 'D').to_i
				growth_inc = book.cell(i, 'C').to_i
				max_growth = book.cell(i, 'G').to_i
				@@dinosaurs_exp[level] = exp
				@@dinosaurs_training_info[level] = {
					:gold => gold_cost,
					:max_growth => max_growth,
					:growth_inc => growth_inc
				}

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
				skills = book.cell(i, "W").split(',').map(&:to_i)
				# Quality:
				quality_A = book.cell(i, 'M').to_f
				quality_B = book.cell(i, 'N').to_f
				quality_C = book.cell(i, 'O').to_f
				quality_D = book.cell(i, 'P').to_f
				quality_E = book.cell(i, 'Q').to_f
				# End of Quality
				hatching_time = book.cell(i, 'R').to_i
				unlock_level = book.cell(i, 'S').to_i
				favor_food = book.cell(i, 'U').to_i
				hunger_time = book.cell(i,'V').to_i

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
						:favor_food => favor_food,
						:hunger_time => hunger_time,
					},
					:quality => {
						1 => quality_A,
						2 => quality_B,
						3 => quality_C,
						4 => quality_D,
						5 => quality_E
					},
					:skills => skills,
					:enhance_property => {
						:attack_inc => attack_inc,
						:defense_inc => defense_inc,
						:agility_inc => agility_inc,
						:hp_inc => hp_inc,
					},
					:exp => @@dinosaurs_exp
				}
			end
			@@dinosaurs_const
		end

		def training_info
			if @@dinosaurs_training_info.blank?
				reload!
			end
			@@dinosaurs_training_info
		end


	end
	
	module InstanceMethods
		
		def info
			self.class.info[type]
		end

		def const_skills
			info[:skills]
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

		def quality_value(qua = self.quality)
			val = info[:quality][qua]
			return val.nil? ? 1 : val
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

		def xp
			self.level * 10
		end

		def max_growth_point
			self.class.training_info[level + 1][:max_growth]
		end

		def training_growth
			val = self.class.training_info[level + 1][:growth_inc]
			val ? val : self.level * 1000
		end

		def training_cost
			self.class.training_info[level + 1][:gold]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end