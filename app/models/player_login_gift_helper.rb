module PlayerLoginGiftHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		
	end
	
	def self.included(model)
		model.attribute 	:login_days,		Ohm::DataTypes::Type::Integer
		model.attribute 	:has_gift, 			Ohm::DataTypes::Type::Boolean

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end