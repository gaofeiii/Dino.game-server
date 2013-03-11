class BattleModel
	TOTAL_ROUNDS = 50
	TARGET_TYPE = {
		:village 		=> 1,
		:creeps 		=> 2,
		:gold_mine 	=> 3
	}

	class << self

		# 调用战斗算法之前必须先调用这个方法
		def extend_battle_methods(*battle_objects)
			battle_objects.each do |obj|
				obj.extend(BattlePlayerModule)
				obj[:army].extend(BattleArmyModule)
				obj[:army].each do |fighter|
					fighter.extend(BattleFighterModule)

					# 初始化攻击、防御和血量————卷轴和玩家科技的影响
					attack_inc 	= obj[:player].try(:tech_attack_inc).to_f + obj[:scroll_effect][:attack_inc].to_f
					speed_inc		= obj[:scroll_effect][:speed_inc].to_f # 没有科技对恐龙速度产生影响
					defense_inc = obj[:player].try(:tech_defense_inc).to_f + obj[:scroll_effect][:defense_inc].to_f
					hp_inc			= obj[:player].try(:tech_hp_inc).to_f + obj[:scroll_effect][:hp_inc].to_f

					fighter.curr_attack *= (1 + attack_inc)
					fighter.curr_speed *= (1 + speed_inc)
					fighter.curr_defense *= (1 + defense_inc)
					fighter.curr_hp *= (1 + hp_inc)
					fighter.total_hp *= (1 + hp_inc)
					fighter.skill_trigger_inc = obj[:scroll_effect][:skill_trigger_inc].to_f
					fighter.exp_inc = obj[:scroll_effect][:exp_inc].to_f
					# ======================================

					fighter.army = obj[:army]
					fighter.skills.each{ |sk| sk.extend(SkillModule) }
				end
			end
		end

		# 计算战斗回合伤害，结果记录到result参数中
		# all_rounds: [
		# 	[], [], [], ...
		# ]
		def start_rounds(attacker, defender, result)
			all_fighters = (attacker[:army] + defender[:army]).extend(BattleArmyModule)
			all_fighters.ordered_by!(:speed)

			(1..TOTAL_ROUNDS).each do |round|
				round_info = []

				all_fighters.each do |fighter|
					if fighter.is_dead?
						next
					end

					one_round = {:attacker_id => fighter.id} # 写入result的数据

					# 设置{fighter}为进攻方或者防守方
					if fighter.in?(attacker[:army])
						one_round[:camp] = false
					else
						one_round[:camp] = true
					end

					# 判定{fighter}的流血情况，并写入one_round结果
					bleeding_result = nil
					if fighter.is_bleeding?
						fighter.bleeding_count -= 1
						fighter.curr_hp -= fighter.bleeding_val
						one_round[:attacker_bleeding] = fighter.bleeding_val.to_i
						if fighter.curr_hp < 0
							fighter.curr_hp = 0
							round_info << one_round
						end
					else
						one_round[:attacker_bleeding] = 0
					end

					# 如果{fighter}判定死亡，则跳过进行下一轮
					if fighter.is_dead?
						next
					end

					# 如果{fighter}为晕眩状态，则跳过进行下一轮
					if fighter.is_stunned?
						fighter.stunned_count -= 1
						one_round[:attacker_stunned] = true
						next
					else
						one_round[:attacker_stunned] = false
					end

					# 随机找出对方一名hp大于0的对象{dest}
					camp = false
					dest = if fighter.in?(attacker[:army])
						# camp = false
						defender[:army].find_an_alive
					else
						camp = true
						attacker[:army].find_an_alive
					end

					# 如果找不出{dest}说明对方所有可战fighter的数量为零，则判定输赢，战斗结束
					if dest.nil?
						round_info << one_round
						result[:all_rounds] << round_info
						result[:all_rounds].each do |a_round|
							if a_round.blank?
								result[:all_rounds].delete(a_round)
							end
						end
						return
					end

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
					skill_effect = {}
					skill_result = nil
					fighter.skills.each do |skill|
						if not skill.triggered
							if skill.trigger?(fighter.skill_trigger_inc)
								case skill.effect_key
								when :double_damage	# 双倍伤害
									skill_effect = {:double_damage => 2.0}
								when :stun 					# 晕眩
									if !dest.is_stunned?
										dest.stunned_count = skill.effect_value
									end
								when :defense_inc_all # 增加己方防御
									fighter.army.each do |fr|
										fr.curr_defense = fr.curr_defense * (1 + skill.effect_value)
									end
									skill.triggered = true 	# 全体性技能只能被触发一次，设置一个标识
								when :attack_inc_all 	# 增加己方攻击
									fighter.army.each do |fr|
										fr.curr_attack = fr.curr_attack * (1 + skill.effect_value)
									end
									skill.triggered = true 	# 全体性技能只能被触发一次，设置一个标识
								when :attack_inc_self_bleeding # 根据自己流血情况增加伤害
									extra_damage = (((fighter.total_hp - fighter.curr_hp) / fighter.total_hp) * 100).to_i
									skill_effect = {:extra_damage => extra_damage}
								when :attack_inc_enemy_bleeding # 根据敌方流血情况增加伤害
									extra_damage = (((dest.total_hp - dest.curr_hp) / dest.total_hp) * 100).to_i
									skill_effect = {:extra_damage => extra_damage}
								when :attack_desc # 降低所有敌方攻击
									dest.army.each do |fr|
										fr.curr_attack = fr.total_attack * (1 - skill.effect_value)
									end
									skill.triggered = true
								when :defense_desc # 降低所有敌方防御
									dest.army.each do |fr|
										fr.curr_defense = fr.curr_defense * (1 - skill.effect_value)
									end
									skill.triggered = true
								when :bleeding # 流血技能，使敌方下一回合起每回合损失HP
									dest.bleeding_count = 1
									dest.bleeding_val = skill.effect_value
								when :attack_desc # 降低敌方单体的攻击
									dest.curr_attack = dest.curr_attack * (1 - skill.effect_value)
									skill.triggered = true
								when :defense_desc # 降低敌方单体的防御
									dest.curr_defense = dest.curr_defense * (1 - skill.effect_value)
									skill.triggered = true
								end
								skill_result = skill.type
							end
						end
					end.compact # End of skill judging

					# 2 - 计算真实伤害
					speed_ratio = (fighter.curr_speed / (fighter.curr_speed + dest.curr_speed))
					factor_k = if speed_ratio < 0.5
						rand(1.01..1.2)
					elsif speed_ratio == 0.5
						1.0
					else
						rand(0.8..0.99)
					end

					damage = (fighter.curr_attack * 5 * (1 / (1 + dest.curr_defense / 136)) * factor_k).to_i

					# 增加技能对伤害的影响
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
					result[:total_rounds] = round

				end # End of each fighters

				result[:all_rounds] << round_info
				# 判断双方是否还有可以战斗的fighter
				if attacker[:army].all_curr_hp.zero? || defender[:army].all_curr_hp.zero?
					return
				end
				
			end # End all rounds
			result[:all_rounds].each do |a_round|
				if a_round.blank?
					result[:all_rounds].delete(a_round)
				end
			end
		end

		# 普通战斗计算，返回战斗结果
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
		def normal_attack(attacker = {}, defender = {})
			self.extend_battle_methods(attacker, defender)

			result = {
				:attacker => attacker.to_hash,
				:defender => defender.to_hash,
				:all_rounds => []
			}

			# 计算战斗回合
			self.start_rounds(attacker, defender, result)

			# 处理战斗结果
			if attacker[:army].all_curr_hp.zero?
				result[:winner] = 'defender'
				attacker[:is_win] = false
				defender[:is_win] = true
				write_result(attacker, defender, :exp, :hp)
				return result.merge!(:time => Time.now.to_f)
			elsif defender[:army].all_curr_hp.zero?
				result[:winner] = 'attacker'
				attacker[:is_win] = true
				defender[:is_win] = false
				write_result(attacker, defender, :exp, :hp)
				return result.merge!(:time => Time.now.to_f)
			else
				p "--- #{__FILE__}:#{__LINE__}"
			end

			return result
		end # End of method: attack_calc

		# 荣誉战斗计算
		def match_attack(attacker = {}, defender = {})
			self.extend_battle_methods(attacker, defender)

			result = {
				:attacker => attacker.to_hash,
				:defender => defender.to_hash,
				:all_rounds => [],
				:reward => {}
			}

			self.start_rounds(attacker, defender, result)

			if attacker[:army].all_curr_hp.zero?
				result[:winner] = 'defender'
				attacker[:is_win] = false
				defender[:is_win] = true
				write_result(attacker, defender, :exp)
				return result.merge!(:time => Time.now.to_f)
			elsif defender[:army].all_curr_hp.zero?
				result[:winner] = 'attacker'
				attacker[:is_win] = true
				defender[:is_win] = false
				write_result(attacker, defender, :exp)
				return result.merge!(:time => Time.now.to_f)
			end
			return result
		end

		# options => :exp, :hp
		def write_result(attacker = {}, defender = {}, *options)
			# attacker[:army].write_hp!(attacker[:is_win], defender)
			# defender[:army].write_hp!(defender[:is_win], attacker)
			attacker[:army].write_army!(attacker[:is_win], defender, attacker[:player], options)
			defender[:army].write_army!(defender[:is_win], attacker, defender[:player], options)
		end

		def write_xp(attacker, defender)
			attacker[:army].write_xp!(attacker[:is_win], defender)
			defender[:army].write_xp!(defender[:is_win], attacker)
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

	def earn_exp(exp)
		self[:player].earn_exp!(exp) if self[:player]
	end
end

module BattleFighterModule
	attr_accessor :curr_attack, :curr_defense, :curr_speed, :curr_hp, :total_hp, :skills, :stunned_count,
		:bleeding_count, :bleeding_val, :army, :skill_trigger_inc, :exp_inc

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

	def skill_trigger_inc
		@skill_trigger_inc ||= 0
		@skill_trigger_inc
	end

	def exp_inc
		@exp_inc ||= 0
		@exp_inc
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
			:name => name,
			:status => status
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

			target[:army].each do |enemy|
				total_exp += enemy.xp.to_i
				total_level += enemy.level.to_i
			end

			target_count = target[:army].size
			target_count = 1 if target_count <= 0
			enemy_avg_level = total_level / target_count
			enemy_avg_level = 1 if enemy_avg_level <= 0

			each_exp = total_exp / alive_count
			player_exp = Player.battle_exp[enemy_avg_level]
		end

		self.each do |fighter|
			new_atts = {}

			if write_xp && fighter.curr_hp > 0
				fighter.experience += each_exp
				new_atts[:experience] = fighter.experience
			end

			new_atts[:current_hp] = fighter.curr_hp if write_hp

			fighter.sets(new_atts) unless new_atts.blank?
		end

		if player && is_win && player_exp > 0
			player.earn_exp!(player_exp)
		end
	end

	def write_xp!(is_win, target)
		return false if self.first.is_a?(Monster)

		earn_xp_fighters_count = self.select{ |fighter| fighter.curr_hp > 0 }.size
		every_exp = 0
		if is_win
			total_exp = target[:army].sum{ |enemy| enemy.xp.to_i }
			every_exp = total_exp / earn_xp_fighters_count
		end

		self.each do |fighter|
			exp = fighter.curr_hp > 0 ? fighter.experience + every_exp : fighter.experience
			fighter.set :experience, exp
		end

	end

	def write_hp!(is_win, target)
		return false if self.first.is_a?(Monster)

		earn_xp_fighters_count = self.select{ |fighter| fighter.curr_hp > 0 }.size
		every_exp = 0
		if is_win
			total_exp = target[:army].sum{ |enemy| enemy.xp.to_i }
			every_exp = total_exp / earn_xp_fighters_count
		end

		self.each do |fighter|
			if fighter.is_a?(Monster)
				return false
			end
			exp = fighter.curr_hp > 0 ? fighter.experience + every_exp : fighter.experience
			fighter.sets 	:current_hp => fighter.curr_hp,
										:updated_hp_time => Time.now.to_i,
										:experience => exp
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