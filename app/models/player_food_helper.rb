module PlayerFoodHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		def find_food_by_type(type)
			foods.find(:type => type).first
		end
		
		def receive_food!(food_type, food_count = 0)
	  	food = find_food_by_type(food_type)
	  	if food.nil?
	  		food = Specialty.create(:type => food_type, :count => food_count, :player_id => id)
	  	else
	  		food.increase(:count, food_count)
	  	end
	  end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end