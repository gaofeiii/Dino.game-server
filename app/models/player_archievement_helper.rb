# Only inlcuded by Player class
module PlayerArchievementHelper
	module ClassMethods
		@@archieve_const = Hash.new
		
		def load_archieve_const!
			@@archieve_const.clear
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end