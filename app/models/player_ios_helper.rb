module PlayerIosHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		def send_push(message)
			send_push_message(:device_token => device_token, :message => message)
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end