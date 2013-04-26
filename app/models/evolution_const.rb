module EvolutionConst
	module ClassMethods
		@@egg_evolution_const = {}
		
		def load_evolution_const!
			book = Roo::Excelx.new("#{Rails.root}/const/evolution.xlsx")

			book.default_sheet = 'egg+'

			3.upto(book.last_row).each do |i|
				egg_type = book.cell(i, 'A').to_i
				quality_1_supply = book.cell(i, 'c').to_i
				quality_2_supply = book.cell(i, 'd').to_i
				quality_3_supply = book.cell(i, 'e').to_i
				quality_4_supply = book.cell(i, 'f').to_i
				quality_5_supply = book.cell(i, 'g').to_i

				quality_1_need = 0
				quality_2_need = book.cell(i, 'h').to_i
				quality_3_need = book.cell(i, 'i').to_i
				quality_4_need = book.cell(i, 'j').to_i
				quality_5_need = book.cell(i, 'k').to_i

				@@egg_evolution_const[egg_type] = {
					1 => { :supply => quality_1_supply, :need => quality_1_need },
					2 => { :supply => quality_2_supply, :need => quality_2_need },
					3 => { :supply => quality_3_supply, :need => quality_3_need },
					4 => { :supply => quality_4_supply, :need => quality_4_need },
					5 => { :supply => quality_5_supply, :need => quality_5_need },
				}
			end
		end

		def evolution_const
			if @@egg_evolution_const.blank?
				load_evolution_const!
			end
			@@egg_evolution_const
		end
	end
	
	module InstanceMethods
		
		def supply_evolution
			return 0 if not is_egg?

			self.class.evolution_const[item_type][quality].try('[]', :supply).to_i
		end

		def next_evolution_exp
			return 99999999 if not is_egg?

			val = self.class.evolution_const[item_type][quality + 1].try('[]', :need).to_i
			val <= 0 ? 99999999 : val
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end