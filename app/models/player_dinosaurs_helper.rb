module PlayerDinosaursHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		def next_dino_space_gems
	  	case dinosaurs_capacity
	  	when 0
	  		1
	  	when 1..4
	  		dinosaurs_capacity * 5
	  	when 5..9
	  		(dinosaurs_capacity - 4) * 25
	  	else
	  		150
	  	end
	  end

	  def released_dinosaurs_ids
	  	db.smembers(key[:released_dinosaurs])
	  end

	  def update_adapt_level
	  	dino_ids = self.dinosaurs.ids

	  	return false if dino_ids.empty?

	  	levels = dino_ids.map{|dino_id| db.hget("Dinosaur:#{dino_id}", :level).to_i}

	  	new_level = levels.max
	  	new_level = 1 if new_level <= 0

	  	self.set :adapt_level, new_level
	  end
	end
	
	def self.included(model)
		model.attribute :dinosaurs_capacity, 		Ohm::DataTypes::Type::Integer

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end