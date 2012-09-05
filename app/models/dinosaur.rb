class Dinosaur < Ohm::Model
	STATUS = {:egg => 0, :infancy => 1, :adult => 2}
	EVENTS = {:hatch => 1}
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

	class << self
		def info
			DINOSAURS
		end
	end

	def info
		DINOSAURS[type]
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
		if event_type == EVENTS[:hatch]
			init_atts
		else
			false
		end
	end

	def update_status
		case event_type
		when 0
			return false
		when EVENTS[:hatch]
			if ::Time.now.to_i >= finish_time
				init_atts
			else
			end
		end
		self
	end

	def update_status!
		update_status
		save
	end

	def init_atts
		[:attack, :defense, :agility, :hp].each do |att|
			send("basic_#{att}=", info[:property][att])
			send("total_#{att}=", send("basic_#{att}"))
		end
		self.level = 1
		self.experience = 0
		self.status = 1
		self.event_type = 0
		self.emotion = EMOTIONS[:normal]
		self.feed_point = 1
		self.updated_feed_time = Time.now.to_i
	end

	def eat!(food)
		self.emotion = if is_my_favorite_food(food.type)
			EMOTIONS[:happy]
		else
			EMOTIONS[:normal]
		end
		self.increase(:feed_point, d.info[:property][:hunger_time])
		food.increase(:count, -1)
		save
	end

	def is_my_favorite_food(food_type)
		info[:property][:favor_food] == food_type
	end

	protected

	def before_save
		# [:attack, :defense, :agility].each do |att|
		# 	send("total_#{att}=", send("basic_#{att}"))
		# end
		self.feed_point -= Time.now.to_i - updated_feed_time
	end


end













