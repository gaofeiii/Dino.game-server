class Troops < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :dinosaurs, 	Type::Array
	attribute :target_type,	Type::Integer
	attribute :target_id
	attribute :start_time,	Type::Integer
	attribute :arrive_time, Type::Integer
	attribute :monster_type, Type::Integer
	attribute :target_x,		Type::Integer
	attribute :target_y,		Type::Integer
	attribute :scroll_id
	attribute :scroll_type,	Type::Integer

	reference :player, Player

	def to_hash
		hash = {
			:id => id,
			:dinosaurs => dinosaurs,
			:target_type => target_type,
			:target_id => target_id.to_i,
			:total_time => arrive_time - start_time + 2,
			:time_pass => Time.now.to_i - start_time,
			:x => target_x,
			:y => target_y
		}
		if target.is_a?(Creeps)
			hash[:monster_type] = monster_type
		end
		hash
	end

	def target
		case target_type
		when BattleModel::TARGET_TYPE[:village]
			Village[target_id]
		when BattleModel::TARGET_TYPE[:creeps]
			Creeps[target_id]
		when BattleModel::TARGET_TYPE[:gold_mine]
			GoldMine[target_id]
		end
	end

	# TODO: 事务的bug
	def refresh!
		if target.nil?
			self.dissolve!
			return
		end
		
		scroll = Item[scroll_id]

		self.mutex(5) do
			if Time.now.to_i >= arrive_time
				army = dinosaurs.map do |dino_id|
					dino = Dinosaur[dino_id]
					if dino && dino.status > 0
						dino.update_status!
						dino
					end
				end.compact
				attacker_army = army
				bill_number = player.curr_bill_quest.try("[]", :number)

				if target.nil? || target.is_a?(Village) && target.is_bill? && bill_number.nil?
					self.dissolve!
					return
				end

				defender_army = target.defense_troops(bill_number)

				attacker = {
					:player => player,
					:owner_info => {
						:type => 'Player',
						:id => player_id.to_i,
						:name => player.nickname,
						:avatar_id => player.avatar_id
					},
					:scroll_type => scroll_type, # Note: Only ruby 2.0+
					:buff_info => [],
					:army => attacker_army
				}
				attacker[:buff_info] << scroll.to_hash if scroll

				defender_name = nil
				defender_type = nil
				defense_player = nil

				if target_type == BattleModel::TARGET_TYPE[:village]
					defender_name = target.player_name
					defense_player = target.player
				elsif target_type == BattleModel::TARGET_TYPE[:creeps]
					defender_name = "Creeps"
					defender_type = target.type
				elsif target_type == BattleModel::TARGET_TYPE[:gold_mine]
					defender_name = target.owner_name
					defense_player = target.player
				end
				defender = {
					:player => defense_player,
					:owner_info => {
						:type => target.class.name,
						:id => target.id,
						:name => defender_name,
						:monster_type => target.type
					},
					:buff_info => [],
					:scroll_type => 0,
					:army => defender_army
				}

				if defense_player
					defender[:owner_info][:monster_type] = 0
					defender[:owner_info][:avatar_id] = defense_player.avatar_id
				end

				defender[:owner_info][:avatar_id] = target.player.avatar_id if target.is_a?(Village)

				result = BattleModel.normal_attack(attacker, defender)
				
				# 如果进攻方获胜，计算奖励
				reward = {}
				if result[:winner] == 'attacker'
					reward = case target_type
					when BattleModel::TARGET_TYPE[:village]
						if target.is_bill?
							player.curr_bill_quest[:finished_steps] = 1
							player.set :kill_bill_quests, player.kill_bill_quests.to_json
							defender_army.map(&:delete)
							{}
						else
							# 判断日常任务
							if not player.finish_daily_quest
								player.daily_quest_cache[:attack_players] += 1
								player.set :daily_quest_cache, player.daily_quest_cache
							end

							# 主线任务
							player.serial_tasks_data[:attack_players] ||= 0
							player.serial_tasks_data[:attack_players] += 1
							player.set :serial_tasks_data, player.serial_tasks_data

							if target.in_dangerous_area?
								tx, ty, ti = target.x, target.y, target.index
								target.move_to_random_coords
								target.set :protection_until, ::Time.now.to_i + 10.minutes
								self.player.village.update :x => tx, :y => ty, :index => ti
							else
								target.set :protection_until, ::Time.now.to_i + 3.hours.to_i
							end

							target_player = defense_player

							stolen_rate = 0.1 + player.tech_plunder_inc

							rwd = {
								:wood => (target_player.wood * stolen_rate).to_i, 
								:stone => (target_player.stone * stolen_rate).to_i,
								:gold_coin => (target_player.gold_coin * stolen_rate).to_i
							}

							player.serial_tasks_data[:rob_gold] ||= 0
							player.serial_tasks_data[:rob_gold] += rwd[:gold_coin]
							player.set :serial_tasks_data, player.serial_tasks_data

							target_player.spend!(rwd) # The target lost resource
							self.player.receive!(rwd) # The winner receive resource
							# i_cat = [1,2,3].sample
							# i_type = Item.const[i_cat].keys.sample
							# i_count = i_cat == 2 ? 99 : 1
							# rwd[:items] << {:item_cat => i_cat, :item_type => i_type, :item_count => i_count}
							target.set(:under_attack, 0)

							attacker_vil = Village.new(:id => player.village_id).gets(:x, :y)
							GameMail.create_village_defense_lose 	:attacker_id 		=> player.id,
																										:attacker_name 	=> player.nickname,
																										:defender_id 		=> target_player.id, 
																										:defender_name 	=> target_player.nickname,
																										:x 							=> attacker_vil.x,
																										:y 							=> attacker_vil.y,
																										:locale 				=> target_player.locale,
																										:rate 					=> (stolen_rate * 100).to_i
							rwd
						end
						
					when BattleModel::TARGET_TYPE[:creeps]
						reward = Reward.monster_rewards(target.type)
						
						if not player.finish_daily_quest
							player.daily_quest_cache[:kill_monsters] += 1
							player.set :daily_quest_cache, player.daily_quest_cache.to_json
						end

						player.del_temp_creeps(target.index)
						target.delete
						# player.receive_reward!(reward)
						player.get_reward(reward)
						reward.to_hash

					when BattleModel::TARGET_TYPE[:gold_mine]
						
						if target.type == GoldMine::TYPE[:normal]
							# 判断主线任务
							player.serial_tasks_data[:occupy_gold_mines] ||= 0
							player.serial_tasks_data[:occupy_gold_mines] += 1

							player.serial_tasks_data[:attack_level_3_mine] ||= 0
							player.serial_tasks_data[:attack_level_3_mine] += 1

							# 判断日常任务
							if not player.finish_daily_quest
								player.daily_quest_cache[:occupy_gold_mines] += 1
								# player.set :daily_quest_cache, player.daily_quest_cache.to_json
							end

							player.save # For quest judging


							if not target.player_id.blank?
								target_player = target.player

								if target_player.nil?
									self.dissolve! and return
								end

								ax, ay = db.hmget(Village.key[player.village_id], :x, :y).map!(&:to_i)

								# (attacker_id:nil, attacker_name:nil, defender_id:nil, defender_name:nil, gx:0, gy:0, ax:0, ay:0, locale:'en')
								GameMail.create_goldmine_defense_lose :attacker_id 					=> player.id,
																											:attacker_name 				=> player.nickname,
																											:defender_id 					=> target_player.id,
																											:defender_name 				=> target_player.nickname,
																											:gx => target.x, 	:gy => target.y,
																											:ax => ax, 				:ay => ay,
																											:locale 							=> target_player.locale
							end

							target.update :player_id => player.id, 
														:under_attack => false,
														:occupy_time => ::Time.now.to_i,
														:update_gold_time => ::Time.now.to_i
							target.strategy.try(:delete)

							rwd = Reward.monster_rewards(target.level)

							player.get_reward(rwd)
							rwd.to_hash
						else # if goldmine's is league

							# 判断主线任务
							player.serial_tasks_data[:occupy_league_gold_mines] ||= 0
							player.serial_tasks_data[:occupy_league_gold_mines] += 1

							player_league = player.league
							unless player_league.nil?
								pg = target.add_attacking_count(player.league_id)
								self.player.increase(:experience, 25)
								player.league_member_ship.increase(:contribution, 25)
								result[:league_war_result] = {:progress => pg, :rank => rand(1..10)}
								target.update :league_id => player_league.id
							end

							player.save # For quest judging
							{} # reward = {}
						end
						
					else
						{}
					end
				else # attacker lose
					case target_type
					when BattleModel::TARGET_TYPE[:village]
						return nil if target.nil?
						
						attacker_vil = Village.new(:id => player.village_id).gets(:x, :y)

						GameMail.create_village_defense_win :attacker_id 		=> player.id,
																								:attacker_name 	=> player.nickname,
																								:defender_id 		=> defense_player.id,
																								:defender_name 	=> defense_player.nickname,
																								:x 							=> attacker_vil.x,
																								:y 							=> attacker_vil.y,
																								:locale 				=> defense_player.locale

					when BattleModel::TARGET_TYPE[:gold_mine]
						if not target.player_id.blank?
							target_player = target.player
							ax, ay = db.hmget(Village.key[player.village_id], :x, :y).map!(&:to_i)

							GameMail.create_goldmine_defense_win	:attacker_id 					=> player.id,
																										:attacker_name 				=> player.nickname,
																										:defender_id 					=> target_player.id,
																										:defender_name 				=> target_player.nickname,
																										:gx => target.x, 	:gy => target.y,
																										:ax => ax, 				:ay => ay,
																										:locale 							=> target_player.locale
						end
					end
				end # End of winner reward

				# Check beginning guide
				if player.has_beginner_guide?
					player.cache_beginner_data(:has_attacked_monster => true)
				end
				
				result[:reward] ||= {}
				result[:reward].merge!(reward)
				# result.merge!(:reward => reward)				
				
				player.save_battle_report(self.id, result)
				self.dissolve!
			end
		end
	end

	def dissolve!
		self.dinosaurs.each do |dino_id|
			next if dino_id <= 0

			db.hset(Dinosaur.key[dino_id], :action_status, Dinosaur::ACTION_STATUS[:idle])
		end
		delete
	end

protected
	def after_create
		Background.add_queue(self.class, self.id, "refresh!", self.arrive_time)
	end

end
