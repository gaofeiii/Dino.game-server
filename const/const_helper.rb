module ConstHelper
	RESOURCES = [:wood, :food, :population]
	module SingleHelper
		def cost
			self[:cost]
		end

		def property
			self[:property]
		end
	end

	module TypeHelper
		def level(lv)
			self.try('[]', lv).extend(SingleHelper)
		end
	end

	module BuildingConstHelper
		def type(tp)
			self.try('[]', tp).extend(SingleHelper)
		end
	end

	module TechnologiesConstHelper
		def type(tp)
			self.try('[]', tp).extend(TypeHelper)
		end
	end
end