class BattleModel

	class << self

		def extend_battle_army(*armys)
			armys.each do |army|
				army.each do |fighter|
					fighter.extend(BattleFighterModule)
					fighter.skills.each do |skill|
						skill.extend(SkillModule)
					end
				end
				army.extend(BattleArmyModule)
			end
		end

		# Battle Model Algorithm
		# Note: Bofore calling this method, the params should extend :extend_batthe_army method.
		# 
		# Parameters:
		# => attacker: must be an array, including one or more figters. Each fighter has included XXXFighterMethod.
		# => defender: the same as attacker
		# 
		def attack!(attacker = [], defender = [])
			# 保存战斗结果的hash
			# Result data structure: one round of a pair of fighters, no matter friend or enemy
			# - source(hash)
			# - dest(hash)
			# - skill
			# - skill_effect
			# - damage
			# - healed
			# 
			# Result sample:
			# result = {
			# 	1 => [
			# 		{
			# 			:
			# 		}
			# 	]
			# }


			# result[0] = {
				
			# }

			1.upto(TOTAL_ROUNDS) do |round|
				# Reorder attacker and defender by fighter's speed, the dead fighter(hp <= 0) will be placed in the end of army.
				attacker.ordered_by!(:speed)
				defender.ordered_by!(:speed)

				## By default, the attacker side is the first to act.
				# Attacker action!
				puts "[Round #{round}]\n"
				puts "--- Attacker Action: ---"
				attacker.attack_army(defender)

				# Defender action!
				puts "--- Defender Action: ---"
				defender.attack_army(attacker)

				puts "[Round #{round} end]\n\n"

				if attacker.all_curr_hp <= 0
					puts "\n Defender wins!"
					return "Defender wins"
				end

				if defender.all_curr_hp <= 0
					puts "\n Attacker wins!"
					return "Attacker wins"
				end
			end
			puts "\n Draw!"
		end # End of method: attack


	end

end

module BattleFighterModule
	attr_accessor :curr_attack, :curr_defense, :curr_speed, :curr_hp, :total_hp, :skills, :key, :stunned_count

	def curr_attack
		@curr_attack ||= self.total_attack
		@curr_attack
	end

	def curr_defense
		@curr_defense ||= self.total_defense
		@curr_defense
	end

	def curr_speed
		@curr_speed ||= self.total_agility
		@curr_speed
	end

	def curr_hp
		@curr_hp ||= current_hp
		@curr_hp
	end

	def total_hp
		@total_hp ||= total_hp
		@total_hp
	end

	def skills
		@skills ||= super.to_a
		@skills
	end

	def key
		@key ||= super
		@key
	end

	def stunned_count
		@stunned_count ||= 0
		@stunned_count
	end

	def is_dead?
		return curr_hp.zero?
	end

	def curr_info
		{
			:attack => curr_attack,
			:defense => curr_defense,
			:speed => curr_speed,
			:curr_hp => curr_hp
		}
	end
end

# Used for extending army
module BattleArmyModule
	attr_accessor :team_buffs

	# Sort army self by given attribute, in ASC order. The element who's hp <= 0 will be placed in the end.
	def ordered_by!(att)
		self.sort! { |element| element.is_dead? ? 0 : element.send(att) }
		self.reverse!
	end

	def find_an_alive

		# self.map { |fighter| fighter unless fighter.is_dead? }.compact.sample
		self.select { |fighter| !fighter.is_dead? }.sample
	end

	def all_curr_hp
		self.sum { |fighter| fighter.curr_hp }.to_f
	end

	def all_total_hp
		self.sum { |fighter| fighter.total_hp }.to_f
	end

	def team_buffs
		@team_buffs ||= []
		@team_buffs
	end

	def attack_army(army)
		self.each do |fighter|
			if fighter.is_dead?
				next
			end

			dest = army.find_an_alive
			if dest.nil?
				return
			end

			puts "find_an_alive:#{dest.curr_hp}"

			hp_before = dest.curr_hp

			## 伤害计算模型公式

			# 1 - 判断技能触发
			trig_skills = fighter.skills.select { |skill| skill.taken_effect_count == 0 && skill.trigger? }
			skill_effects = {}
			trig_skills.map do |skill|
				if skill_effects[skill.effect_key].nil?
					skill_effects[skill.effect_key] = skill.effect_value
				else
					skill_effects[skill.effect_key] += skill.effect_value
				end
			end

			# 2 - 计算真实伤害
			speed_ratio = (fighter.curr_speed / (fighter.curr_speed + dest.curr_speed))
			factor_k = if speed_ratio < 0.5
				rand(1.01..1.2)
			elsif speed_ratio == 0.5
				1.0
			else
				rand(0.8..0.99)
			end

			puts "--- factor_k: #{factor_k}"

			damage = (fighter.curr_attack * 5 * (1 / (1 + dest.curr_defense / 10)) * factor_k).to_i

			if skill_effects[:damage_inc].to_f > 0
				old_damage = damage
				damage *= skill_effects[:damage_inc].to_f
				puts "[[[$$$ triggered skill: damage X2 (#{old_damage}->#{damage})]]]"
			end
			# skill_effects.each do |s_key, s_val|
			# 	case s_key
			# 	when :damage_inc
			# 		old_damage = damage
			# 		damage *= s_val
			# 		puts "[[[$$$ triggered skill: damage X2 (#{old_damage}->#{damage})]]]"
			# 	end
			# end

			if damage < 0
				next
			end

			if damage > dest.curr_hp
				damage = dest.curr_hp
			end

			dest.curr_hp -= damage
			hp_later = dest.curr_hp
			puts "A kills B: #{damage.to_i} hp!"
			puts "B's hp: #{hp_before.to_i}->#{hp_later.to_i}"
		end
		
	end
end

# Used for extending skill
module SkillModule
	attr_accessor :taken_effect_count

	def taken_effect_count
		@taken_effect_count ||= 0
		@taken_effect_count
	end

	def trigger?
		if trigger_chance >= 1
			return true
		elsif trigger_chance <= 0
			return false
		else
			trig_factor = trigger_chance * 10000
			rand(1..10000) <= trig_factor ? true : false
		end
	end

	def effect
		case type
		when 1
			{:damage_inc => 2.0}
		when 2
			{:attack => 10}
		end
	end

	def effect_key
		case type
		when 1
			:damage_inc
		when 2
			:attack
		end
	end

	def effect_value
		case type
		when 1
			2.0
		when 2
			10			
		end
	end

end

SkillBuff = Struct.new(:type, :level, :is_taken_effect)

# Used for extending buff(Ruby Struct)
module BuffModule

	def to_hash
		hash_result = {}
		members.each do |att|
			hash_result[att] = send(att)
		end
		hash_result
	end
end