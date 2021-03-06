class Dinosaur < Ohm::Model
	STATUS = {:egg => 0, :infancy => 1, :adult => 2}
	EVENTS = {:hatching => 1}
	EMOTIONS = {:happy => 2, :normal => 1, :angry => 0}
	ACTION_STATUS = {
		:idle => 0, 
		:deployed => 1, 
		:deployed_village => 1, 
		:deployed_gold => 2, 
		:attacking => 3
	} # deployed = deployed_village
	COMSUME_PER_SECOND = 5
	HEALED_PER_SECOND = 5

	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps

	include OhmExtension
	include DinosaursConst

	include Fighter

	attribute :name
	attribute :level, 				Type::Integer
	attribute :experience, 		Type::Integer
	attribute :type, 					Type::Integer
	attribute :status, 				Type::Integer # Expired attribute
	attribute :emotion, 			Type::Integer
	attribute :feed_point, 		Type::Integer
	attribute :updated_feed_time, Type::Integer

	attribute :feed_weight, 	Type::Integer
	attribute :feed_count, 		Type::Integer

	attribute :quality,						Type::Integer
	attribute :action_status,			Type::Integer # 恐龙的攻击状态 - see ACTION_STATUS

	attribute :updated_hp_time, 	Type::Integer

	attribute :is_deployed,				Type::Boolean
	attribute :is_attacking,			Type::Boolean

	attribute :event_type, 		Type::Integer
	attribute :start_time, 		Type::Integer
	attribute :finish_time, 	Type::Integer

	attribute :growth_times,	Type::Integer

	attribute :building_id, 	Type::Integer

	attribute :strategy_id, 	Type::Integer
	def strategy
		Strategy[strategy_id]
	end
	

	reference :player, 		Player
	reference :village, 	Village

	index :level
	index :type
	index :status
	index :is_attacking

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

	def speed
		total_agility
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
			:attack => total_attack,
			:max_attack => max_attack,
			:defense => total_defense,
			:max_defense => max_defense.to_i,
			:agility => total_agility,
			:max_agility => max_agility,
			:hp => current_hp.to_i,
			:total_hp => total_hp.to_i,
			:total_feed_point => property[:hunger_time],
			:quality => quality,
			:is_attacking => is_attacking,
			:is_deployed => is_deployed,
			:training_cost_gold => training_cost,
			:growth_point => growth_times,
			:max_growth_point => max_growth_times,
			:action_status => action_status
		}

		hash[:total_time] = finish_time - start_time
		hash[:time_pass] = Time.now.to_i - start_time
		if event_type != 0
			# hash[:event_type]  = event_type
			# hash[:total_time] = finish_time - start_time
			# hash[:time_pass] = Time.now.to_i - start_time
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

	def hatch_speed_up_cost_gems
		((finish_time - ::Time.now.to_i) / 300.0).ceil
	end

	# Update consuming...
	# Update auto healing...
	# Check if upgraded...
	def update_status
		if event_type == EVENTS[:hatching]
			if ::Time.now.to_i >= finish_time
				init_atts

				return self
			end
		elsif status > 0
			consume_food
			update_level
			auto_healing
			return self
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
		# 主线任务：孵化紫色恐龙蛋
		@player = self.player

		if @player
			@player.serial_tasks_data[:hatch_purple_dino] ||= 0
			@player.serial_tasks_data[:hatch_purple_dino] += 1 if quality == 4
			@player.serial_tasks_data[:hatch_orange_dino] ||= 0
			@player.serial_tasks_data[:hatch_orange_dino] += 1 if quality == 5
			@player.set :serial_tasks_data, @player.serial_tasks_data
		end

		[:attack, :defense, :agility, :hp].each do |att|
			send("basic_#{att}=", (info[:property][att] * rand(0.8..1.2)).round(1))
			send("total_#{att}=", send("basic_#{att}"))
		end
		self.level = 1
		self.experience = 0
		self.status = 1
		self.event_type = 0
		self.emotion = EMOTIONS[:normal]
		self.feed_point = self.hunger_time * 0.3
		self.updated_feed_time = Time.now.to_i
		self
	end

	def upgrade_atts
		factor = case emotion
		when EMOTIONS[:happy]
			Random.rand(8..12) / 10.0 * info[:quality][quality]
		when EMOTIONS[:normal]
			Random.rand(5..10) / 10.0 * info[:quality][quality]
		else
			0
		end

		@player = self.player
		if @player
			@player.serial_tasks_data[:max_dino_level] ||= 0
			@player.serial_tasks_data[:max_dino_level] = level if @player.serial_tasks_data[:max_dino_level] < level
			@player.set :serial_tasks_data, @player.serial_tasks_data
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
		until experience < next_level_exp
			self.experience -= next_level_exp
			self.level += 1
			self.growth_times = 0

			upgrade_atts

			self.current_hp = self.total_hp
			if self.level.in?([1, 2])
				self.total_hp = self.basic_hp
			end

			self.status = STATUS[:adult] if level >= 8
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

	def consume_energy(energy: 0)
		return if energy <= 0

		if self.feed_point < energy
			self.set(:feed_point, 0)
		else
			self.increase(:feed_point, -energy)
		end
	end

	def eat!(food, count = 1)
		need_count = (hunger_time - self.feed_point) / food.feed_point + 1

		if count > need_count
			count = need_count
		end

		if is_my_favorite_food(food.type)
			self.emotion = EMOTIONS[:happy]
		else
			self.emotion = EMOTIONS[:angry]
		end

		self.feed_point += food.feed_point * count
		self.feed_point = hunger_time if feed_point > hunger_time
		
		food.increase(:count, -count)
		consume_food
		save
	end

	def auto_healing
		time = ::Time.now.to_i
		dt = time - updated_hp_time

		healed_per_second = total_hp / (level * 60)

		dhp = dt / healed_per_second
		return false if dhp < 1

		self.current_hp += dhp
		self.current_hp = total_hp if self.current_hp > total_hp

		self.updated_hp_time = time
		self
	end

	def auto_healing!
		auto_healing
		self.sets :current_hp => self.current_hp, :updated_hp_time => self.updated_hp_time
	end

	def heal_speed_up_cost
		{:gems => level / 10 + 1}
	end

	def heal_speed_up!
		self.set :current_hp, total_hp
	end

	def max_attack
		56 + 24 * level
	end

	def max_agility
		28 + 24 * level
	end

	def max_defense
		39 + 24 * level
	end

	def max_growth_times
		5
	end

	def quality_factor
		case quality
		when 1
			1
		when 2
			1.1
		when 3
			1.2
		when 4
			1.3
		when 5
			1.4
		else
			1
		end
	end

	def training!(att)
		return false if growth_times >= max_growth_times || !att.in?(:attack, :defense, :agility)

		growth = info[:enhance_property]["#{att}_inc".to_sym].to_f * 0.1 * quality_factor
		curr_val = send("basic_#{att}")

		send("basic_#{att}=", curr_val + growth)
		send("total_#{att}=", curr_val + growth)

		self.growth_times += 1
		save
	end

	protected

	def before_save
		self.name = info[:name].classify if name.blank?
		self.updated_hp_time = Time.now.to_i if updated_hp_time.zero?
		self.quality = 1 if quality.zero?
	end

	def before_create
		self.current_hp = total_hp
		self.updated_hp_time = Time.now.to_i if updated_hp_time.zero?
		self.quality = 1 if quality.zero?
		self.feed_point = self.hunger_time * 0.5
	end

	def after_create
		if self.skills.blank?
			Skill.create :type => self.const_skills.sample, :level => 1, :dinosaur_id => id
		end
	end


end













