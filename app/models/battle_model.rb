class BattleModel
	TOTAL_ROUNDS = 50
	TARGET_TYPE = {
		:village 		=> 1,
		:creeps 		=> 2,
		:gold_mine 	=> 3
	}

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
		# => attacker structure:
		# {
		# 	:owner_info => {
		# 		:type => integer,
		# 		:id => integer or string
		# 	},
		# 	:buff_info => {},
		# 	:army => fihgters(dinosaurs) array
		# }
		# => defender: The same as attacker
		def attack_calc(attacker = {}, defender = {})
			[attacker, defender].each do |er|
				er.extend(BattlePlayerModule)
				er[:army].extend(BattleArmyModule)
				er[:army].each do |fighter|
					fighter.extend(BattleFighterModule)
					fighter.army = er[:army]
					fighter.skills.each{ |skl| skl.extend(SkillModule) }
				end
			end

			result = {
				:attacker => attacker.to_hash,
				:defender => defender.to_hash,
				:all_rounds => []
			}

			all_fighters = (attacker[:army] + defender[:army]).extend(BattleArmyModule)
			all_fighters.ordered_by!(:speed)
			(1..TOTAL_ROUNDS).each do |round|		
				puts "*********** Round #{round} ***********"
				round_info = []
				all_fighters.each do |fighter|
					puts "*-*- Start -*-*\n"

					one_round = {:attacker_id => fighter.id}

					if fighter.in?(attacker[:army])
						one_round[:camp] = false
					else
						one_round[:camp] = true
					end

					bleeding_result = nil
					if fighter.is_bleeding?
						fighter.bleeding_count -= 1
						fighter.curr_hp -= fighter.bleeding_val
						one_round[:attacker_bleeding] = fighter.bleeding_val.to_i
						if fighter.curr_hp < 0
							fighter.curr_hp = 0
							round_info << one_round
						end
						puts "----- I'm Bleeding, lost #{fighter.bleeding_val} blood"
					else
						one_round[:attacker_bleeding] = 0
					end

					if fighter.is_dead?
						next
					end

					if fighter.is_stunned?
						puts "------- I'm Stunned!!! -------\n\n"
						fighter.stunned_count -= 1
						one_round[:attacker_stunned] = true
						next
					else
						one_round[:attacker_stunned] = false
					end


					# 随机找出对方一名hp大于0的对象
					camp = false
					fighter_name, d_name = "", ''
					dest = if fighter.in?(attacker[:army])
						d = defender[:army].find_an_alive
						# camp = false
						fighter_name, d_name = "A*[#{fighter.id}]", "B*[#{d.id}]" if fighter && d
						d
					else
						d = attacker[:army].find_an_alive
						camp = true
						fighter_name, d_name = "B*[#{fighter.id}]", "A*[#{d.id}]" if fighter && d
						d
					end

					if dest.nil?
						if attacker[:army].all_curr_hp.zero?
							result[:winner] = 'defender'
							puts "$$ Defender win!!! $$"
						elsif defender[:army].all_curr_hp.zero?
							result[:winner] = 'attacker'
							puts "$$ Attacker win!!! $$"
						end

						break
					end

					hp_before = dest.curr_hp

					## 伤害计算模型公式

					# 1 - 判断技能触发
					# trig_skills = fighter.skills.select { |skill| skill.taken_effect_count == 0 && skill.trigger? }
					# skill_effects = {}
					# trig_skills.map do |skill|
					# 	if skill_effects[skill.effect_key].nil?
					# 		skill_effects[skill.effect_key] = skill.effect_value
					# 	else
					# 		skill_effects[skill.effect_key] += skill.effect_value
					# 	end
					# end
					skill_effect = nil
					skill_result = nil
					fighter.skills.map do |skill|
						if not skill.triggered
							if skill.trigger?
								puts "~~~~~~~ Skill Triggered! ~~~~~~"
								puts "~~~~~~~ Type:#{skill.type} ~~~~~~"
								case skill.effect_key
								when :double_damage
									puts "<<< Double Damage >>>"
									skill_effect = skill.effect
								when :stun
									puts "<<< Stun Enemy >>>"
									dest.stunned_count = skill.effect_value
									nil
								when :defense_inc_all
									puts "<<< Increase All Defense >>>"
									puts "<<<--- Before self.defense: #{fighter.curr_defense} --->>>"
									fighter.army.each do |fr|
										fr.curr_defense = fr.curr_defense * (1 + skill.effect_value)
									end
									puts "<<<--- After self.defense: #{fighter.curr_defense} --->>>"
									nil
								when :attack_inc_all
									puts "<<< Increase All Attack >>>"
									puts "<<<--- Before self.attack: #{fighter.curr_attack} --->>>"
									fighter.army.each do |fr|
										fr.curr_attack = fr.curr_attack * (1 + skill.effect_value)
									end
									puts "<<<--- After self.attack: #{fighter.curr_attack} --->>>"
									nil
								when :attack_inc_self_bleeding
									extra_damage = (((fighter.total_hp - fighter.curr_hp) / fighter.total_hp) * 100).to_i
									puts "<<< Attack Increase when Bleeding >>>"
									puts "<<<--- Extra Damage: #{extra_damage} --->>>"
									skill_effect = {:extra_damage => extra_damage}
								when :attack_inc_enemy_bleeding
									puts "<<< Attack Bleeding Increase >>>"
									extra_damage = (((dest.total_hp - dest.curr_hp) / dest.total_hp) * 100).to_i
									puts "<<<--- Extra Damage: #{extra_damage} --->>>"
									skill_effect = {:extra_damage => extra_damage}
								when :attack_desc
									puts "<<< Descrease All Attack >>>"
									puts "<<<--- Before enemy.attack: #{dest.curr_attack} --->>>"
									dest.army.each do |fr|
										fr.curr_attack = fr.total_attack * (1 - skill.effect_value)
									end
									puts "<<<--- After enemy.attack: #{dest.curr_attack} --->>>"
									nil
								when :defense_desc
									puts "<<< Descrease All Attack >>>"
									puts "<<<--- Before enemy.defense: #{dest.curr_defense} --->>>"
									dest.army.each do |fr|
										fr.curr_defense = fr.curr_defense * (1 - skill.effect_value)
									end
									puts "<<<--- After enemy.defense: #{dest.curr_defense} --->>>"
									nil
								when :bleeding
									puts "<<< Make Bleeding >>>"
									dest.bleeding_count = 1
									dest.bleeding_val = skill.effect_value
									nil
								when :attack_desc
									puts "<<< Descrease Attack >>>"
									dest.curr_attack = dest.curr_attack * (1 - skill.effect_value)
									nil
								when :defense_desc
									# puts "<<< Descrease Defense >>>"
									dest.curr_defense = dest.curr_defense * (1 - skill.effect_value)
									nil
								end
								skill_result = skill.type
							end
						end
					end.compact # End of skill judging
					p '++= skill_effect', skill_effect

					# 2 - 计算真实伤害
					speed_ratio = (fighter.curr_speed / (fighter.curr_speed + dest.curr_speed))
					factor_k = if speed_ratio < 0.5
						rand(1.01..1.2)
					elsif speed_ratio == 0.5
						1.0
					else
						rand(0.8..0.99)
					end

					# puts "--- factor_k: #{factor_k}"

					damage = (fighter.curr_attack * 5 * (1 / (1 + dest.curr_defense / 10)) * factor_k).to_i
					puts "===== The Origin Damage: #{damage} ====="

					# if skill_effects[:damage_inc].to_f > 0
					# 	old_damage = damage
					# 	damage *= skill_effects[:damage_inc].to_f
					# 	puts "[[[$$$ triggered skill: damage X2 (#{old_damage}->#{damage})]]]"
					# end
					if skill_effect
						skill_effect.each do |effect_k, effect_v|
							case effect_k
							when :double_damage
								damage *= effect_v
							when :extra_damage
								damage += effect_v
							end
						end
					end
						
					puts "===== The Final Damage: #{damage} ====="

					if damage < 0
						next
					end

					if damage > dest.curr_hp
						damage = dest.curr_hp
					end

					dest.curr_hp -= damage
					hp_later = dest.curr_hp
					one_round.merge!({
						:target_id => dest.id,
						:damage => damage.to_i,
						:camp => camp
					})
					one_round[:skill_type] = skill_result if skill_result

					round_info << one_round
					puts "$ - #{fighter_name} kills #{d_name}: #{damage.to_i} hp!"
					puts "    #{d_name}'s hp: #{hp_before.to_i}->#{hp_later.to_i}\n\n"
					result[:total_rounds] = round
				end # End of each fighters
				result[:all_rounds] << round_info

				puts "*********** End Round #{round} ***********\n\n"
				if attacker[:army].all_curr_hp.zero?
					puts "$$ Defender win!!! $$"
					result[:winner] = 'defender'
					write_result(attacker, defender)
					return result.merge!(:time => Time.now.to_f)
				elsif defender[:army].all_curr_hp.zero?
					result[:winner] = 'attacker'
					write_result(attacker, defender)
					puts "$$ Attacker win!!! $$"
					return result.merge!(:time => Time.now.to_f)
				end
			end # End all rounds

			return result
		end # End of method: attack_calc

		def write_result(attacker = {}, defender = {})
			[attacker[:army], defender[:army]].each do |army|
				army.write_hp!
			end
		end
	end

end

module BattlePlayerModule

	def to_hash
		army = self[:army].map(&:curr_info)
		{
			:owner_info => self[:owner_info],
			:buff_info => self[:buff_info],
			:army => army
		}
	end
end

module BattleFighterModule
	attr_accessor :curr_attack, :curr_defense, :curr_speed, :curr_hp, :total_hp, :skills, :stunned_count,
		:bleeding_count, :bleeding_val, :army

	def curr_attack
		@curr_attack ||= self.total_attack
		@curr_attack
	end

	def curr_defense
		@curr_defense ||= self.total_defense
		@curr_defense
	end

	def speed
		curr_speed
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
		@total_hp ||= super
		@total_hp
	end

	def skills
		@skills ||= super.to_a
		@skills
	end

	def stunned_count
		@stunned_count ||= 0
		@stunned_count
	end

	def is_stunned?
		stunned_count > 0
	end

	def is_dead?
		return curr_hp.zero?
	end

	def is_bleeding?
		bleeding_count > 0
	end

	def bleeding_count
		@bleeding_count ||= 0
		@bleeding_count
	end

	def bleeding_val
		@bleeding_val ||= 0
		@bleeding_val
	end

	def curr_info
		hash = {
			:id => id,
			:type => type,
			:level => level,
			:quality => quality,
			:attack => curr_attack.to_i,
			:defense => curr_defense.to_i,
			:speed => curr_speed.to_i,
			:curr_hp => curr_hp.to_i,
			:total_hp => total_hp.to_i,
			:name => name
		}
		hash[:monster_type] = monster_type
		return hash
	end

	def monster_type
		case self.class.name
		when "Dinosaur"
			1
		when "Monster"
			2
		else
			0
		end
	end
end

# Used for extending army
module BattleArmyModule
	attr_accessor :team_buffs, :team

	# Sort army self by given attribute, in ASC order.
	def ordered_by!(att)
		self.sort_by! { |element| element.send(att).to_f }.reverse!
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

	def to_hash
		self.map do |fighter|
			fighter.curr_info
		end
	end

	def write_hp!
		puts "=== Writing hp... ==="
		self.each do |fighter|
			if fighter.is_a?(Monster)
				return
			end
			puts "-- fighter: #{fighter.current_hp} => #{fighter.curr_hp}"
			fighter.sets 	:current_hp => fighter.curr_hp,
										:updated_hp_time => Time.now.to_i
		end
	end

end

# Used for extending skill
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

	def trigger?
		if trigger_chance >= 1
			return true
		elsif trigger_chance <= 0
			return false
		else
			Tool.rate(trigger_chance)
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