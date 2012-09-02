module ConstHelper
	RESOURCES = [:wood, :food, :population]
	module SingleHelper
		def type
			self[:type]
		end

		def cost
			self[:cost]
		end

		def property
			self[:property]
		end

		def enhance_property
			self[:enhance_property]
		end

		def condition
			self[:condition]
		end
	end

	module TypeHelper
		def level(lv)
			self.try('[]', lv).extend(SingleHelper)
		end

		alias :number :level
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

	module ItemsConstHelper
		def type(tp)
			self.try('[]', tp).extend(TypeHelper)
		end
	end

	module DinosaursConstHelper
		def type(tp)
			self.try('[]', tp).extend(SingleHelper)
		end
	end
end