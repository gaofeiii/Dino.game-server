module Fighter
	module ClassMethods
		
	end
	
	module InstanceMethods
		
	end
	
	def self.included(model)
		# Extra attributes...
		model.attribute 	:basic_attack, 			Ohm::DataTypes::Type::Float			# 基础攻击
		model.attribute 	:basic_defense, 		Ohm::DataTypes::Type::Float			# 基础防御
		model.attribute 	:basic_agility,			Ohm::DataTypes::Type::Float 		# 基础敏捷
		model.attribute 	:basic_hp,					Ohm::DataTypes::Type::Float
		model.attribute 	:total_attack, 			Ohm::DataTypes::Type::Float
		model.attribute 	:total_defense, 		Ohm::DataTypes::Type::Float
		model.attribute 	:total_agility,			Ohm::DataTypes::Type::Float
		model.attribute 	:total_hp,					Ohm::DataTypes::Type::Float
		model.attribute 	:current_hp, 				Ohm::DataTypes::Type::Float

		# Extra collections...
		model.collection 	:skills, 						Skill

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end