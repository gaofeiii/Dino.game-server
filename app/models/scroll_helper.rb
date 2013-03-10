module ScrollHelper
	module ClassMethods
		@@scroll_const = Hash.new
		
		def scroll_const(type = nil)
			if @@scroll_const.blank?
				reload_scroll!
			end
			
			if type
				@@scroll_const[type] ? @@scroll_const[type] : {}
			else
				@@scroll_const
			end
		end

		def reload_scroll!
			@@scroll_const.clear
			@@scroll_const = {
				1 => {:attack_inc => 0.05},
				2 => {:defense_inc => 0.05},
				3 => {:speed_inc => 0.05},
				4 => {:hp_inc => 0.05},
				5 => {:skill_trigger_inc => 0.05},
				6 => {:exp_inc => 0.05},
			}
		end
	end
	
	module InstanceMethods
		
		def is_scroll?
			self.item_category == Item.categories[:scroll]
		end

		def scroll_effect
			if is_scroll?
				self.class.scroll_const(item_type)
			else
				{}
			end
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end