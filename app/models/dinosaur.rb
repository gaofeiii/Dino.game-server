class Dinosaur < Ohm::Model
	STATUS = {:egg => 0, :infancy => 1, :adult => 2}
	EVENTS = {:hatching => 1}
	EMOTIONS = {:happy => 2, :normal => 1, :angry => 0}

	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps

	include OhmExtension

	attribute :name
	attribute :level, 				Type::Integer
	attribute :experience, 		Type::Integer
	attribute :type, 					Type::Integer
	attribute :status, 				Type::Integer
	attribute :emotion, 			Type::Integer
	# attribute :hungry_time,		Type::Integer
	attribute :feed_point, 		Type::Integer
	attribute :updated_feed_time, Type::Integer

	attribute :feed_weight, 	Type::Integer
	attribute :feed_count, 		Type::Integer

	attribute :basic_attack, 			Type::Integer			# 基础攻击
	attribute :basic_defense, 		Type::Integer			# 基础防御
	attribute :basic_agility,			Type::Integer 		# 基础敏捷
	attribute :basic_hp,					Type::Integer
	attribute :total_attack, 			Type::Integer
	attribute :total_defense, 		Type::Integer
	attribute :total_agility,			Type::Integer
	attribute :total_hp,					Type::Integer


	attribute :event_type, 		Type::Integer
	attribute :start_time, 		Type::Integer
	attribute :finish_time, 	Type::Integer


	reference :player, 		Player
	reference :village, 	Village
	reference :troops, 		Troops

	class << self
		def info
			DINOSAURS
		end
	end

	def info
		DINOSAURS[type]
	end

	def next_level_exp
		DINOSAUR_EXPS[level + 1]
	end

	def to_hash
		hash = {
			:id => id.to_i,
			:name => name,
			:level => level,
			:experience => experience,
			:type => type,
			:status => status,
			:emotion => emotion,
			:hungry_time => Time.now.to_i + feed_point,
			:attack => total_attack,
			:defense => total_defense,
			:agility => total_agility,
			:hp => total_hp
		}

		if event_type != 0
			hash[:event_type]  = event_type,
			hash[:start_time]  = start_time,
			hash[:finish_time] = finish_time
		end
		return hash
	end

	def hatch_speed_up!
		if event_type == EVENTS[:hatching]
			init_atts
			save
		else
			false
		end
	end

	def update_status
		if event_type == EVENTS[:hatching]
			if ::Time.now.to_i >= finish_time
				init_atts
				return self
			end
		elsif status > 0
			consume_food
			update_level
		else
			return false
		end
	end

	def update_status!
		if update_status
			save
		else
			false
		end
	end

	def init_atts
		[:attack, :defense, :agility, :hp].each do |att|
			send("basic_#{att}=", (info[:property][att] * rand(0.8..1.2)).to_i)
			send("total_#{att}=", send("basic_#{att}"))
		end
		self.level = 1
		self.experience = 0
		self.status = 1
		self.event_type = 0
		self.emotion = EMOTIONS[:normal]
		self.feed_point = 1
		self.updated_feed_time = Time.now.to_i
		self
	end

	def update_atts
		factor = case status
		when STATUS[:happy]
			0.8..1.2
		when STATUS[:normal]
			0.5..1.0
		else
			0
		end
		self.basic_attack += info[:enhance_property][:attack_inc] * factor.to_i
		self.basic_defense += info[:enhance_property][:defense_inc] * factor.to_i
		self.basic_agility += info[:enhance_property][:agility_inc] * factor.to_i
		self.basic_hp += info[:enhance_property][:hp_inc] * factor.to_i
	end

	def update_level
		if experience > next_level_exp
			self.experience -= next_level_exp
			self.level += 1
			update_atts
		end
	end

	def consume_food
		curr_time = Time.now.to_i
		time = curr_time - updated_feed_time
		consume = feed_point < time ? feed_point : time
		self.feed_point -= consume
		self.updated_feed_time = curr_time
	end

	def eat!(food)
		self.emotion = if is_my_favorite_food(food.type)
			EMOTIONS[:happy]
		else
			EMOTIONS[:normal]
		end
		curr_feed_point = feed_point + food.feed_point
		curr_feed_point = curr_feed_point > hunger_time ? hunger_time : curr_feed_point
		self.set(:feed_point, curr_feed_point)
		food.increase(:count, -1)
		consume_food
		save
	end

	def favor_food
		property[:favor_food]
	end

	def property
		info[:property]
	end

	def hunger_time
		property[:hunger_time]
	end

	def is_my_favorite_food(food_type)
		info[:property][:favor_food] == food_type
	end

	protected

	def before_save
		# [:attack, :defense, :agility].each do |att|
		# 	send("total_#{att}=", send("basic_#{att}"))
		# end
		# self.feed_point -= Time.now.to_i - updated_feed_time
		self.name = 'Earthquake' if name.blank?
	end


end













