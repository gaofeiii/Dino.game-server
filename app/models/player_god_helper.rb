module PlayerGodHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		
		def save!
			self.god_taken_effect_time = ::Time.now.to_i if god_taken_effect_time.zero?
			super
		end

		def curr_god
			gods.first
		end

	end
	
	def self.included(model)
		model.attribute 	:god_taken_effect, 			Ohm::DataTypes::Type::Boolean
		model.attribute 	:god_taken_effect_time, Ohm::DataTypes::Type::Integer
		model.collection 	:gods, 									God

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end