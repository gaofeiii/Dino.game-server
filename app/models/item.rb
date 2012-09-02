class Item < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include OhmExtension

	attribute :item_type, 	Type::Integer
	attribute :item_number, Type::Integer
	reference :player, :Player

	def info
		ITEMS[item_type][item_number]
	end

	def use!
		item_info = info

		obj = case item_info[:type]
		when ITEM_TYPES[:egg]
			dino = DINOSAURS[item_info[:type]]
			Dinosaur.create :type 				=> item_info[:type],
											:status 			=> Dinosaur::STATUS[:egg],
											:event_type 	=> Dinosaur::EVENTS[:hatch],
											:start_time 	=> ::Time.now.to_i,
											:finish_time 	=> ::Time.now.to_i + dino[:property][:hatching_time],
											:player_id 		=> player_id
		end
		return obj
	end

	def to_hash
		{
			:id => id.to_i,
			:type => item_type,
			:number => item_number
		}
	end
end
