module RankModel
	module ClassMethods
		def total_rank
			
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.attribute :rank
		
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end