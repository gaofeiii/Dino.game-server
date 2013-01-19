module GodConst

	module ClassMethods
		@@hashes = {
			:intelligence => 1,	# 智力之神
			:business			=> 2, # 商业之神
			:war		  		=> 3, # 战争之神
			:argriculture => 4  # 农业之神
		}

		@@gods = {
			1 => {
				:name => :god_of_argriculture,
			},
			2 => {
				:name => :god_of_business,
			},
			3 => {
				:name => :god_of_war,
			},
			4 => {
				:name => :god_of_intelligence,
			},
		}
		
		def hashes
			@@hashes
		end

		def const
			@@gods
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end




