module BasicTask
	module ClassMethods
		
	end
	
	module InstanceMethods
		def not_finished
			!finished
		end

		def not_rewarded
			!rewarded
		end

		def is_finished
			finished
		end

		def is_rewarded
			rewarded
		end
		
		def to_hash
			
		end

		def set_rewarded(ret)
			self.set :rewarded, ret
		end
	end
	
	def self.included(model)
		model.attribute :index, 						Ohm::DataTypes::Type::Integer
		model.attribute :finished_steps, 		Ohm::DataTypes::Type::Integer
		model.attribute :finished,					Ohm::DataTypes::Type::Boolean
		model.attribute :rewarded,					Ohm::DataTypes::Type::Boolean

		model.index :index
		model.index :finished
		model.index :rewarded

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end