class Dinosaur < Ohm::Model
	STATUS = {:egg => 0, :infancy => 1, :adult => 2}
	EVENTS = {:hatching => 1}
	EMOTIONS = {:happy => 2, :normal => 1, :angry => 0}

	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps

	include OhmExtension
	include DinosaursConst

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

	attribute :basic_attack, 			Type::Float			# 基础攻击
	attribute :basic_defense, 		Type::Float			# 基础防御
	attribute :basic_agility,			Type::Float 		# 基础敏捷
	attribute :basic_hp,					Type::Float
	attribute :total_attack, 			Type::Float
	attribute :total_defense, 		Type::Float
	attribute :total_agility,			Type::Float
	attribute :total_hp,					Type::Float

	attribute :current_hp, 				Type::Float


	attribute :event_type, 		Type::Integer
	attribute :start_time, 		Type::Integer
	attribute :finish_time, 	Type::Integer

	collection :skills, 	Skill

	reference :player, 		Player
	reference :village, 	Village
	reference :troops, 		Troops

	index :level
	index :status

	class << self
		
		def new_by(args = {})
			if args.has_key?(:type)
				dino = self.new(:type => args[:type].to_i)
				dino.init_atts
				dino.update_attributes(args)
				dino
			else
				raise "Args must include type"
			end
		end

		def create_by(args = {})
			self.new_by(args).save
		end
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
			:feed_point => feed_point,
			:hungry_time => Time.now.to_i + feed_point,
			:attack => total_attack.to_i,
			:defense => total_defense.to_i,
			:agility => total_agility.to_i,
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
			send("basic_#{att}=", (info[:property][att] * rand(0.8..1.2)).round(1))
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

	def upgrade_atts
		factor = case emotion
		when EMOTIONS[:happy]
			Random.rand(8..12) / 10.0
		when EMOTIONS[:normal]
			Random.rand(5..10) / 10.0
		else
			0
		end

		self.basic_attack += (info[:enhance_property][:attack_inc] * factor).round(1)
		self.basic_defense += (info[:enhance_property][:defense_inc] * factor).round(1)
		self.basic_agility += (info[:enhance_property][:agility_inc] * factor).round(1)
		self.basic_hp += (info[:enhance_property][:hp_inc] * factor).round(1)
		update_main_atts

		if skills.blank?
			Skill.create :type => info[:skill_type], :level => 1
		else
			# TODO: Upgrade skill level when dinosaur was upgraded.
		end

		self
	end

	def update_main_atts
		[:attack, :defense, :agility, :hp].each do |att|
			send("total_#{att}=", send("basic_#{att}"))
		end
	end

	def update_level
		if experience > next_level_exp
			self.experience -= next_level_exp
			self.level += 1
			upgrade_atts
		end
	end

	def consume_food
		curr_time = Time.now.to_i
		time = curr_time - updated_feed_time
		consume = feed_point < time ? feed_point : time
		self.feed_point -= consume
		self.emotion = EMOTIONS[:angry] if feed_point <= 0
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

	protected

	def before_save
		# [:attack, :defense, :agility].each do |att|
		# 	send("total_#{att}=", send("basic_#{att}"))
		# end
		# self.feed_point -= Time.now.to_i - updated_feed_time
		self.name = info[:name] if name.blank?
	end

	def before_create
		self.current_hp = total_hp
	end


end













