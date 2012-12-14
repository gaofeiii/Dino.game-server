# encoding: utf-8
module SkillConst
	module ClassMethods
		@@skill_const = Hash.new

		def const
			if @@skill_const.blank?
				reload!
			end
			return @@skill_const
		end

		def reload!
			book = Excelx.new("#{Rails.root}/const/dinosaurs.xlsx")
			book.default_sheet = "skills"

			
		end
		
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end