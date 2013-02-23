# encoding: utf-8
module SkillConst
	module ClassMethods
		@@skill_const = Hash.new
		@@skill_types = Array.new

		def const
			if @@skill_const.blank?
				reload!
			end
			@@skill_const
		end
		alias info const

		def types
			if @@skill_types.blank?
				reload!
			end
			@@skill_types
		end

		def reload!
			book = Roo::Excelx.new("#{Rails.root}/const/dinosaurs.xlsx")
			book.default_sheet = "skill_avai"

			2.upto(12) do |i|
				key_name = book.cell(i, 'B').downcase.to_sym
				type = book.cell(i, 'D').to_i
				chance = book.cell(i, 'E').to_f
				permanent = book.cell(i, 'F').to_i > 0

				@@skill_const[type] = {
					:key => key_name,
					:trigger_chance => chance,
					:permanent => permanent
				}
				@@skill_types << type
			end
			
		end
		
	end
	
	module InstanceMethods
		
		def trigger_chance
			self.class.const[type][:trigger_chance]
		end

		def permanent?
			self.class.const[type][:permanent]
		end

		def key_name
			self.class.const[type][:key]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end