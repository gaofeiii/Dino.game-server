module PlayerAdvisorHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		
		def adv_inc_resource
			
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end