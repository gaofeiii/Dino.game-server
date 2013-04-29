# battler_1 = {
# 	:player => @player,
# 	:owner_info => {
# 		:type => 'Player',
# 		:id => @player.id,
# 		:name => @player.nickname,
# 		:avatar_id => @player.avatar_id
# 	},
# 	:buff_info => [],
# 	:scroll_type => scroll_type,
# 	:army => player_dinos
# }

# battler_2 = {
# 	:player => nil,
# 	:owner_info => {
# 		:type => 'Creeps',
# 		:id => @cave.id,
# 		:name => @cave.name(:locale => @player.locale),
# 		:avatar_id => 0,
# 		:monster_type => enemy_dinos.sample.type
# 	},
# 	:buff_info => [],
# 	:scroll_effect => {},
# 	:army => enemy_dinos
# }
module BattleArmy
	attr_accessor :camp, :player

	# Sort army self by given attribute, in ASC order.
	def ordered_by!(att)
		self.sort_by! { |element| element.send(att).to_f }.reverse!
	end

	def find_an_alive
		self.select { |fighter| !fighter.is_dead? }.sample
	end

	def all_curr_hp
		self.sum { |fighter| fighter.curr_hp }.to_f
	end

	def all_total_hp
		self.sum { |fighter| fighter.total_hp }.to_f
	end

	def camp
		@camp ||= false
		@camp
	end

	def player
		@player
	end

	def to_hash
		self.map do |fighter|
			fighter.curr_info
		end
	end

	# options => :exp, :hp
	def write_army!(is_win, target, player = nil, options = [])
		return false if self.first.is_a?(Monster)
		return false if options.blank?

		write_xp = options.include?(:exp)
		write_hp = options.include?(:hp)

		alive_count = self.select{ |fighter| fighter.curr_hp > 0 }.size

		each_exp = 0
		player_exp = 0

		enemy_avg_level = 1

		if is_win && write_xp
			total_exp = 0
			total_level = 0

			target.army.each do |enemy|
				total_exp += enemy.xp.to_i
				total_level += enemy.level.to_i
			end

			target_count = target.army.size
			target_count = 1 if target_count <= 0
			enemy_avg_level = total_level / target_count
			enemy_avg_level = 1 if enemy_avg_level <= 0

			each_exp = total_exp / alive_count
			player_exp = Player.battle_exp[enemy_avg_level].to_i
		end

		result = []

		result = self.map do |fighter|
			next if fighter.is_advisor

			new_atts = {}

			if write_xp && fighter.curr_hp > 0 && !fighter.is_advisor
				fighter.experience += each_exp
				new_atts[:experience] = fighter.experience
			end

			new_atts[:current_hp] = fighter.curr_hp if write_hp && !fighter.is_advisor

			fighter.sets(new_atts) unless new_atts.blank?

			if write_xp && fighter.curr_hp > 0 && !fighter.is_advisor
				{
					:id => fighter.id,
					:exp_inc => each_exp,
					:is_upgraded => fighter.experience >= fighter.next_level_exp
				}
			end
		end.compact

		if player && is_win && player_exp.to_i > 0
			player.earn_exp!(player_exp)
		end

		result
	end
	
end

module SkillModule
	attr_accessor :taken_effect_count, :triggered

	def taken_effect_count
		@taken_effect_count ||= 0
		@taken_effect_count
	end

	def triggered
		@triggered ||= false
		@triggered
	end

	def trigger?(ext = 0)
		if trigger_chance >= 1
			return true
		elsif trigger_chance <= 0
			return false
		else
			Tool.rate(trigger_chance + ext)
		end
	end

	def effect
		case type
		when 1
			{:double_damage => 2.0}
		when 2
			{:stun => 1}
		when 3
			{:defense_inc_all => 0.1}
		when 4
			{:attack_inc_all => 0.1}
		when 5
			{:attack_inc_self_bleeding => 1.0}
		when 6
			{:attack_inc_enemy_bleeding => 1.0}
		when 7
			{:attack_desc => 0.1}
		when 8
			{:defense_desc => 0.1}
		when 9
			{:bleeding => 10}
		when 10
			{:attack_desc => 0.1}
		when 11
			{:defense_desc => 0.1}
		end
	end

	def effect_key
		effect.keys.first
	end

	def effect_value
		effect.values.first
	end
end

module BattleOwner

	def name(locale: ServerInfo.default_locale)
		case self.class.name
		when "Player"
			self.nickname
		when "Creeps"
			"Creeps"
		when "PlayerCave"
			"Cave #{self.index}"
		else
			"Name"
		end
	end

	def monster_type
		case self.class.name
		when "Player"
			0
		when "Creeps"
			self.type
		else
			1
		end
	end

	def avatar
		self.class.name == "Player" ? avatar_id : 0
	end

	def to_battle_hash(locale: ServerInfo.default_locale)
		{
			:type => self.class.name,
			:id => id,
			:name => name(:locale => locale),
			:avatar_id => avatar,
			:monster_type => monster_type
		}
	end
end


class Battler
	attr_accessor :owner, :army, :scroll_type, :buff_info, :camp

	def initialize(owner: nil, army: [], buff_info: [], camp: false, scroll_type: nil)
		self.scroll_type = scroll_type
		self.owner = owner.extend(BattleOwner)
		self.army = army.extend(BattleArmy)
		self.army.camp = camp
		self.army.player = owner

		self.army.each do |fighter|
			fighter.extend(BattleFighter)
			fighter.init_hp = fighter.curr_hp
			fighter.skills.each{ |sk| sk.extend(SkillModule) }
			fighter.army = self.army
			fighter.camp = camp
			fighter.is_advisor = true if owner && fighter.is_a?(Dinosaur) && fighter.try(:player_id).to_i != owner.id
		end
		self.camp = camp
	end

	def to_hash
		army_hash = self.army.map(&:curr_info)
		{
			:owner_info => owner.to_battle_hash,
			:buff_info => buff_info,
			:army => army_hash
		}
	end

	
end