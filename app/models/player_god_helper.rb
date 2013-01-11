module PlayerGodHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		
		def save!
			self.god_taken_effect_time = ::Time.now.to_i if god_taken_effect_time.zero?
			super
		end

	end
	
	def self.included(model)
		model.attribute :god_taken_effect, Ohm::DataTypes::Type::Boolean
		model.attribute :god_taken_effect_time, Ohm::DataTypes::Type::Integer
		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end