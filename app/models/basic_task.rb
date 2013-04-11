module BasicTask
	module ClassMethods
		
	end
	
	module InstanceMethods
		def to_hash
			
		end
	end
	
	def self.included(model)
		model.attribute :index, 		Ohm::DataTypes::Type::Integer
		model.attribute :finished,	Ohm::DataTypes::Type::Boolean
		model.attribute :rewarded,	Ohm::DataTypes::Type::Boolean

		model.index :index
		model.index :finished
		model.index :rewarded

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end