module LeagueConst
	module ClassMethods
		
		def levels
			{
				:president => 10,
				:vice_president => 9,
				:member => 1
			}
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end