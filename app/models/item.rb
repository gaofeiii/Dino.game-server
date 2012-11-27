class Item < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include OhmExtension

	attribute :item_category, 	Type::Integer
	attribute :item_type, 			Type::Integer
	reference :player, :Player

	def info
		ITEMS[item_category][item_type]
	end

	def use!
		item_info = info
		obj = case item_info[:type]
		when ITEM_TYPES[:egg]
			dino = Dinosaur.const[item_info[:type]]
			Dinosaur.create :type 				=> item_info[:property][:dinosaur_type],
											:status 			=> Dinosaur::STATUS[:egg],
											:event_type 	=> Dinosaur::EVENTS[:hatching],
											:start_time 	=> ::Time.now.to_i,
											:finish_time 	=> ::Time.now.to_i + dino[:property][:hatching_time],
											:player_id 		=> player_id
		end
		self.delete
		return obj
	end

	def to_hash
		{
			:id => id.to_i,
			:category => item_category,
			:type => item_type
		}
	end
end
