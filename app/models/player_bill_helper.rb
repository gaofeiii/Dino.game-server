module PlayerBillHelper
	module ClassMethods
		def bill
			@@bill ||= self.find(:player_type => PlayerTypeHelper::TYPE[:bill]).first
			@@bill
		end

		def bill_village
			@@bill_village ||= self.bill.village
			@@bill_village
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end