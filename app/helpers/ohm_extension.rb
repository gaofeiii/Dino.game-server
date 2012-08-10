module OhmExtension
	module ClassMethods
		def count
			self.all.size
		end

		def first
			self.all.first
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end