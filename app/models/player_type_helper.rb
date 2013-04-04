module PlayerTypeHelper
	TYPE = {
		:normal => 0,
		:vip => 1,
		:npc => 2,
		:bill => 3
	}

	module ClassMethods
		def none_npc
			self.find(:player_type => TYPE[:normal]).union(:player_type => TYPE[:vip])
		end
	end
	
	module InstanceMethods
		def is_npc?
			player_type == TYPE[:npc]
		end

		def is_vip?
			player_type == TYPE[:vip]
		end

		def is_bill?
			player_type == TYPE[:bill]
		end
	end
	
	def self.included(model)
		model.attribute :player_type, 	Ohm::DataTypes::Type::Integer
		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end