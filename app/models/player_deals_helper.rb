module PlayerDealsHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		def my_selling_list
	  	deals
	  end
	end
	
	def self.included(model)
		model.collection :deals, Deal, :seller
		
		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end