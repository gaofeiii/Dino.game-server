 class Item < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include OhmExtension

	attribute :item_category, 	Type::Integer
	attribute :item_type, 			Type::Integer
	attribute :can_sell,				Type::Boolean
	attribute :quality,					Type::Integer

	attribute :evolution_exp,		Type::Integer

	index :item_category

	reference :player, :Player

	include ItemsConst
	include ScrollHelper

	def use!(options = {})
		item_info = info
		obj = case item_category
		# 使用恐龙蛋
		when Item.categories[:egg]
			dino = Dinosaur.const[item_info[:type]]
			building_id = options[:building_id]
			cost_time = dino[:property][:hatching_time] * (1 - player.tech_hatching_inc)
			dino = Dinosaur.new		:type 				=> item_info[:type],
														:status 			=> Dinosaur::STATUS[:egg],
														:event_type 	=> Dinosaur::EVENTS[:hatching],
														:start_time 	=> ::Time.now.to_i,
														:finish_time 	=> ::Time.now.to_i + cost_time,
														:player_id 		=> player_id,
														:quality 			=> self.quality
			dino.building_id = building_id if building_id

			if dino.save
				self.delete
			end
			dino
		# 使用卷轴
		when Item.categories[:scroll]
		when Item.categories[:vip]
			player.player_type = Player::TYPE[:vip]
			now = Time.now.to_i
			if now > player.vip_expired_time
				player.vip_expired_time = now + 1.month.to_i
			else
				player.vip_expired_time += 1.month.to_i
			end
			player.save
		end
		# 使用VIP礼包

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
			:can_sell => false,
			:evolution_exp => evolution_exp,
			:next_evolution_exp => next_evolution_exp
		}
		hash[:quality] = quality if is_egg?
		hash
	end

	def supply_evolution
		5 * (self.quality)
	end

	def next_evolution_exp
		10 * (self.quality + 1)
	end

	def update_evolution
		if evolution_exp >= next_evolution_exp
			self.evolution_exp -= next_evolution_exp
			self.quality += 1
			self.save
		end
	end

	protected
	def before_save
		if is_egg? && self.quality.zero?
			self.quality = 1
		end
	end
end
