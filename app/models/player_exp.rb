#encoding: utf-8

module PlayerExp
	module ClassMethods
		@@exps = Hash.new

		def load_exps!
			@@exps.clear

			book = Roo::Excelx.new("#{Rails.root}/const/exps.xlsx")
			book.default_sheet = 'player_upgrade_exp'

			2.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				need_exp = book.cell(i, 'F').to_i
				@@exps[level] = need_exp
			end
			@@exps
		end

		def all_level_exps
			if @@exps.empty?
				load_exps!
			end
			@@exps
		end
	end
	
	module InstanceMethods
		
		def next_level_exp
			self.class.all_level_exps[self.level + 1]
		end

		def earn_exp!(exps = 0)
			self.experience += exps

			if experience >= next_level_exp
				self.experience -= next_level_exp
				self.level += 1
				return self.save
			else
				return self.sets(:experience => experience)
			end
		end

	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end