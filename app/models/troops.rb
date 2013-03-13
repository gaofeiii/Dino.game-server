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

	def refresh!
		return if target.nil?
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
				defender_army = target.defense_troops

				attacker = {
					:player => player,
					:owner_info => {
						:type => 'Player',
						:id => player_id.to_i,
						:name => player.nickname,
						:avatar_id => player.avatar_id
					},
					:scroll_effect => scroll.try(:scroll_effect).to_h, # Note: Only ruby 2.0+
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
					:scroll_effect => {},
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
						if not player.finish_daily_quest
							player.daily_quest_cache[:attack_players] += 1
							player.set :daily_quest_cache, player.daily_quest_cache.to_json
						end

						if target.in_dangerous_area?
							tx, ty, ti = target.x, target.y, target.index
							target.move_to_random_coords
							target.set :protection_until, ::Time.now.to_i + 10.minutes
							self.player.village.update :x => tx, :y => ty, :index => ti
						end

						target_player = defense_player
						rwd = {:wood => target_player.wood/10, :stone => target_player.stone/10, :gold_coin => target_player.gold_coin/10, :items => []}
						target_player.spend!(rwd) # The target lost resource
						self.player.receive!(rwd) # The winner receive resource
						# i_cat = [1,2,3].sample
						# i_type = Item.const[i_cat].keys.sample
						# i_count = i_cat == 2 ? 99 : 1
						# rwd[:items] << {:item_cat => i_cat, :item_type => i_type, :item_count => i_count}
						target.set(:under_attack, 0)

						attacker_vil = Village.new(:id => player.village_id).gets(:x, :y)
						Mail.create_defense_village_lose_mail :receiver_id => target_player.id, 
																									:receiver_name => target_player.nickname,
																									:attacker => player.nickname,
																									:x => attacker_vil.x,
																									:y => attacker_vil.y,
																									:locale => target_player.locale
						rwd
					when BattleModel::TARGET_TYPE[:creeps]
						reward = Reward.judge!(target.type)
						
						if not player.finish_daily_quest
							player.daily_quest_cache[:kill_monsters] += 1
							player.set :daily_quest_cache, player.daily_quest_cache.to_json
						end

						player.del_temp_creeps(target.index)
						target.delete
						player.receive_reward!(reward)
						reward

					when BattleModel::TARGET_TYPE[:gold_mine]
						if not player.finish_daily_quest
							player.daily_quest_cache[:occupy_gold_mines] += 1
							player.set :daily_quest_cache, player.daily_quest_cache.to_json
						end
						
						if target.type == GoldMine::TYPE[:normal]
							if not target.player_id.blank?
								target_player = target.player
								ax, ay = db.hmget(Village.key[player.village_id], :x, :y).map!(&:to_i)

								Mail.create_goldmine_defense_lose_mail 	:receiver_name => target_player.nickname,
																												:receiver_id => target_player.id,
																												:attacker => player.nickname,
																												:gx => target.x, :gy => target.y,
																												:ax => ax, :ay => ay,
																												:locale => target_player.locale
							end

							target.update :player_id => player.id, 
														:under_attack => false,
														:occupy_time => ::Time.now.to_i,
														:update_gold_time => ::Time.now.to_i
							target.strategy.try(:delete)
							target.move_to_refresh_queue(target.update_gold_time + 1.hour)
							rwd = Reward.judge!(target.level)
							player.receive_reward!(rwd)
							rwd
						else
							unless player.league.nil?
								target.add_attacking_count(player.league_id)
								self.player.increase(:experience, 25)
								player.league_member_ship.increase(:contribution, 25)
								# TODO: league_war result
								result[:league_war_result] = {:progress => rand(1..3000), :rank => rand(1..10)}
							end
							{} # reward = {}
						end
						
					else
						{}
					end
					player.receive!(reward)
				else # attacker lose
					case target_type
					when BattleModel::TARGET_TYPE[:village]
						attacker_vil = Village.new(:id => player.village_id).gets(:x, :y)
						Mail.create_defense_village_win_mail 	:receiver_id => defense_player.id, 
																									:receiver_name => defense_player.nickname,
																									:attacker => player.nickname,
																									:x => attacker_vil.x,
																									:y => attacker_vil.y,
																									:locale => defense_player.locale
					when BattleModel::TARGET_TYPE[:gold_mine]
						if not target.player_id.blank?
							target_player = target.player
							ax, ay = db.hmget(Village.key[player.village_id], :x, :y).map!(&:to_i)

							Mail.create_goldmine_defense_win_mail :receiver_name => target_player.nickname,
																										:receiver_id => target_player.id,
																										:attacker => player.nickname,
																										:gx => target.x, :gy => target.y,
																										:ax => ax, :ay => ay,
																										:locale => target_player.locale
						end
					end
				end # End of winner reward

				# Check beginning guide
				if !player.beginning_guide_finished && !player.guide_cache['attack_monster']
					player.set :guide_cache, player.guide_cache.merge('attack_monster' => true)
				end
				
				result.merge!(:reward => reward)
				
				player.save_battle_report(self.id, result)
				scroll.delete if scroll
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
