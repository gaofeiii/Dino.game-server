class Item < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include OhmExtension

	CATEGORY = ITEM_CATEGORY

	attribute :item_category, 	Type::Integer
	attribute :item_type, 			Type::Integer
	attribute :can_sell,				Type::Boolean
	attribute :quality,					Type::Integer

	index :item_category

	reference :player, :Player

	class << self

		def const
			ITEMS
		end

		def categories
			ITEM_CATEGORY.values
		end

		def types(cat = 0)
			if cat == 0
				return []
			else
				ITEMS[cat].keys
			end
		end
	end

	def info
		ITEMS[item_category][item_type]
	end

	def use!(options = {})
		item_info = info
		obj = case item_info[:type]
		when ITEM_CATEGORY[:egg]
			dino = Dinosaur.const[item_info[:type]]
			building_id = options[:building_id]
			dino = Dinosaur.new		:type 				=> item_info[:property][:dinosaur_type],
														:status 			=> Dinosaur::STATUS[:egg],
														:event_type 	=> Dinosaur::EVENTS[:hatching],
														:start_time 	=> ::Time.now.to_i,
														:finish_time 	=> ::Time.now.to_i + dino[:property][:hatching_time],
														:player_id 		=> player_id
			dino.building_id = building_id if building_id
			if dino.save
				self.delete
			end
		when ITEM_CATEGORY[:scroll]
			if self.delete
				return true
			else
				return false
			end
		end
		return obj
	end

	def is_egg?
		item_category == ITEM_CATEGORY[:egg]
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
