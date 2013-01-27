class Item < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include OhmExtension

	attribute :item_category, 	Type::Integer
	attribute :item_type, 			Type::Integer
	attribute :can_sell,				Type::Boolean
	attribute :quality,					Type::Integer

	index :item_category

	reference :player, :Player

	include ItemsConst

	def use!(options = {})
		item_info = info
		obj = case item_category
		when Item.categories[:egg]
			dino = Dinosaur.const[item_info[:type]]
			building_id = options[:building_id]
			dino = Dinosaur.new		:type 				=> item_info[:type],
														:status 			=> Dinosaur::STATUS[:egg],
														:event_type 	=> Dinosaur::EVENTS[:hatching],
														:start_time 	=> ::Time.now.to_i,
														:finish_time 	=> ::Time.now.to_i + dino[:property][:hatching_time],
														:player_id 		=> player_id,
														:quality 			=> self.quality
			dino.building_id = building_id if building_id
			p dino
			if dino.save
				self.delete
			end
			dino
		when Item.categories[:scroll]
			
		end
		return obj
	end

	def is_egg?
		item_category == Item.categories[:egg]
	end

	def to_hash
		hash = {
			:id => id.to_i,
			:category => item_category,
			:type => item_type,
			:can_sell => false
		}
		hash[:quality] = quality if is_egg?
		hash
	end

	protected
	def before_save
		if is_egg? && self.quality.zero?
			self.quality = 1
		end
	end
end
