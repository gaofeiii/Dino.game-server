class Dinosaur < Ohm::Model
	STATUS = {:egg => 0, :infancy => 1, :adult => 2}
	EVENTS = {:hatching => 1}
	EMOTIONS = {:happy => 2, :normal => 1, :angry => 0}
	COMSUME_PER_SECOND = 5
	HEALED_PER_SECOND = 10

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

	attribute :quality,						Type::Integer

	attribute :current_hp, 				Type::Float
	attribute :updated_hp_time, 	Type::Integer

	attribute :is_deployed,				Type::Boolean
	attribute :is_attacking,			Type::Boolean

	attribute :event_type, 		Type::Integer
	attribute :start_time, 		Type::Integer
	attribute :finish_time, 	Type::Integer

	attribute :building_id

	collection :skills, 	Skill

	reference :player, 		Player
	reference :village, 	Village

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
			:next_exp => next_level_exp,
			:type => type,
			:status => status,
			:emotion => emotion,
			:feed_point => feed_point,
			:hungry_time => Time.now.to_i + feed_point,
			:attack => total_attack.to_i,
			:max_attack => max_attack,
			:defense => total_defense.to_i,
			:max_defense => max_defense.to_i,
			:agility => total_agility.to_i,
			:max_agility => max_agility,
			:hp => current_hp.to_i,
			:total_hp => total_hp.to_i,
			:total_feed_point => property[:hunger_time],
			:quality => quality,
			:is_attacking => is_attacking,
			:is_deployed => is_deployed
		}

		if event_type != 0
			hash[:event_type]  = event_type
			hash[:total_time] = finish_time - start_time
			hash[:time_pass] = Time.now.to_i - start_time
			hash[:building_id] = building_id.to_i if building_id
		end

		if skills.any?
			hash[:skill_type] = self.skills.first.type
		end
		return hash
	end

	def hatch_speed_up!
		if event_type == EVENTS[:hatching]
			init_atts
			self.current_hp = total_hp
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
			auto_heal
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
			if self.level.in?([1, 2])
				self.total_hp = self.basic_hp
			end
		end
		self
	end

	def consume_food(time = Time.now.to_i)
		dt = time - updated_feed_time
		consume = dt > feed_point ? feed_point : dt
		self.feed_point -= consume / COMSUME_PER_SECOND
		self.emotion = EMOTIONS[:angry] if feed_point <= 0
		self.updated_feed_time = time
		consume
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

	def auto_heal(time = ::Time.now.to_i)
		return false if current_hp == total_hp
		dt = time - updated_hp_time
		if dt < HEALED_PER_SECOND
			return false
		else
			d_hp = dt / HEALED_PER_SECOND
			c_hp = current_hp + d_hp
			if c_hp > total_hp
				c_hp = total_hp
			end
			c_hp
		end
	end

	def auto_heal!(time = ::Time.now.to_i)
		if auto_heal(time)
			self.sets :current_hp => self.current_hp,
								:updated_hp_time => time
			return current_hp
		else
			return false
		end
	end

	def heal_speed_up_cost
		{:gems => level * 1}
	end

	def heal_speed_up!
		self.set :current_hp, total_hp
	end

	def max_attack
		255
	end

	def max_agility
		255
	end

	def max_defense
		255
	end

	protected

	def before_save
		# [:attack, :defense, :agility].each do |att|
		# 	send("total_#{att}=", send("basic_#{att}"))
		# end
		# self.feed_point -= Time.now.to_i - updated_feed_time
		self.name = info[:name] if name.blank?
		# self.current_hp = self.total_hp if total_hp.zero?
		self.updated_hp_time = Time.now.to_i if updated_hp_time.zero?
	end

	def before_create
		self.current_hp = total_hp
		self.updated_hp_time = Time.now.to_i if updated_hp_time.zero?
	end

	def after_create
		if self.skills.blank?
			Skill.create :type => Skill.types.sample, :level => 1, :dinosaur_id => id
		end
	end


end













