#encoding: utf-8

module PlayerExp
	module ClassMethods
		@@exps = Hash.new

		def load_exps!
			@@exps.clear

			book = Excelx.new("#{Rails.root}/const/experiences.xlsx")
			book.default_sheet = '玩家升级所需经验'

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
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end