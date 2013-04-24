# attacker = Battler.new(attacker_info)
# defender = Battler.new(defender_info)

# battle = Battle.new(attacker, defender)
# battle.type = normal | match_attack | cave

# battle.calc!
# battle.result
# battle.write_xp
# battle.write_hp

# 一个action是指一个回合中fighter对fighter的动作以及自身的状态
BattleAction = Struct.new(:attacker_id, :target_id, :camp, :attacker_stunned, :attacker_bleeding, :skill_type, :damage) do

	def to_hash
		hash = {}
		hash[:attacker_id] = self.attacker_id
		hash[:attacker_stunned] = !!self.attacker_stunned
		hash[:attacker_bleeding] = self.attacker_bleeding.to_i
		hash[:skill_type] = self.skill_type if self.skill_type
		hash[:target_id] = self.target_id if self.target_id
		hash[:damage] = self.damage.to_i
		hash[:camp] = self.camp
		hash
	end
end

BattleDinoReward = Struct.new(:id, :exp_inc, :is_upgraded) do
	
	def to_hash
		{
			:id => id,
			:exp_inc => exp_inc,
			:is_upgraded => !!is_upgraded
		}
	end
end

BattleReward = Struct.new(:reward, :dino_rewards) do
	def initialize(reward: nil, dino_rewards: [])
		self.reward = reward
		self.dino_rewards = dino_rewards
	end
	
	def to_hash
		hash = {}
		hash.merge(reward.to_hash) if reward
		hash[:dino_rewards] = dino_rewards.map(&:to_hash)
		hash
	end
end

BattleResult = Struct.new(:attacker, :defender, :all_rounds, :reward, :winner) do
	def initialize(attacker: nil, defender: nil)
		self.attacker = attacker
		self.defender = defender
		self.all_rounds = []
		self.reward = BattleReward.new
	end
	
	def clean
		self.all_rounds.delete_if { |round| round.blank? }
	end

	def add_round(round)
		self.all_rounds << round
	end

	def rounds_count
		all_rounds.size
	end

	def judge_winner
		if winner == attacker
			"attacker"
		else
			"defender"
		end
	end

	def to_hash
		hash = {}
		hash[:attacker] = attacker.to_hash
		hash[:defender] = defender.to_hash
		hash[:all_rounds] = all_rounds.map { |round| round.map(&:to_hash) }
		hash[:winner] = judge_winner
		hash[:reward] = reward.to_hash
		hash
	end
end

class Battle
	attr_accessor :attacker, :defender, :type, :result, :winner

	NORMAL = 1	# 普通战役
	HONOUR = 2	# 荣誉战
	CAVE 	 = 3	# 攻打巢穴

	MAX_ROUND = 100 # 设置一个最大回合数

	def initialize(attacker: nil, defender: nil, type: 1)
		self.attacker = attacker
		self.defender = defender
		self.type = type
		self.result = BattleResult.new :attacker => attacker, :defender => defender
	end

	def start!
		start_rounds
		handle_result
	end

	def start_rounds
		# 将所有fighter按速度（敏捷）排序——从高到低
		all_fighters = (attacker.army + defender.army).sort_by!{ |element| element.send(:speed).to_f }.reverse!

		# 计算每个回合(all_fighters中每个fighter进行一次action计算)
		(1..MAX_ROUND).each do |round|
			one_round = []

			all_fighters.each do |fighter|
				next if fighter.is_dead?

				# 初始化action信息
				action = BattleAction.new(fighter.id)
				action.camp = fighter.camp


				# 判定{fighter}的流血情况，并写入action结果
				if fighter.is_bleeding?
					fighter.bleeding_count -= 1
					fighter.curr_hp -= fighter.bleeding_val
					fighter.curr_hp = 0 if fighter.curr_hp < 0

					action[:attacker_bleeding] = fighter.bleeding_val.to_i
				else
					action[:attacker_bleeding] = 0
				end

				# 再次判定{fighter}是否死亡，如果是，写入结果并结束本次循环
				one_round << action && next if fighter.is_dead?
				

				# 如果{fighter}为晕眩状态，则跳过进行下一轮
				if fighter.is_stunned?
					fighter.stunned_count -= 1

					action[:attacker_stunned] = true

					one_round << action && next
				else
					action[:attacker_stunned] = false
				end

				# 随机找出对方一名hp大于0的对象{dest}
				desc_army = attacker.camp == fighter.camp ? defender.army : attacker.army
				dest = desc_army.find_an_alive

				# 如果找不出{dest}说明对方所有可战fighter的数量为零，战斗结束
				if dest.nil?
					break # Break this round (all_fighters.each)
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
							end # End of 'case skill.effect_key'

							skill_result = skill.type
						end # End of 'skill.trigger?'
					end # End of 'not skill.triggered'
				end.compact # End of fighter's skills judging

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

				next if damage < 0 # NOTE: Just record the damage greater than 0

				# 最终造成的伤害
				damage *= (1 + fighter.army.player.tech_damage_inc) if fighter.army.player.is_a?(Player)

				dest.curr_hp -= damage
				dest.curr_hp = 0 if dest.curr_hp < 0

				action.target_id = dest.id
				action.damage = damage
				action.camp = fighter.camp
				action.skill_type = skill_result if skill_result

				one_round << action

			end # End of each all_fighters

			result.add_round(one_round)

			# 判断双方是否还有可以战斗的fighter
			if attacker.army.all_curr_hp.zero? || defender.army.all_curr_hp.zero?
				judge_winner && break # Break all rounds (1..MAX_ROUND)
			end
			
		end # End all rounds

		self.result.clean
	end # End of 'def start_rounds'

	def judge_winner
		if attacker.army.all_curr_hp.zero?
			result.winner = defender
			winner = defender
		elsif defender.army.all_curr_hp.zero?
			result.winner = attacker
			winner = defender
		end
	end

	def handle_result
		case type
		when NORMAL
			write_back_hp!(attacker.army)
			write_back_xp!(attacker.army)
		when HONOUR
			write_back_xp!(attacker.army)
		when CAVE
			write_back_hp!(attacker.army) if result.winner != attacker
			write_back_xp!(attacker.army)
		end
	end

	def write_back_hp!(*fighters)
		
	end

	# Return an Array whose element is BattleDinoReward
	def write_back_xp!(*fighters)
		
	end

end