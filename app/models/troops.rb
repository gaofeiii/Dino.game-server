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
			:total_time => arrive_time - start_time,
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
		when 1
			Village[target_id]
		when 2
			Creeps[target_id]
		when 3
			GoldMine[target_id]
		end
	end

	def refresh!
		return if target.nil?
		scroll = Item[scroll_id]

		if Time.now.to_i >= arrive_time
			army = dinosaurs.map do |dino_id|
				dino = Dinosaur[dino_id]
				if dino && dino.status > 0
					dino.update_status!
					dino
				end
			end.compact
			attacker_army = army.blank? ? player.dinosaurs.to_a.select{|d| d.status > 0}[0, 5] : army
			defender_army = target.defense_troops

			attacker = {
				:owner_info => {
					:type => 'Player',
					:id => player_id.to_i,
					:name => player.nickname,
					:avatar_id => player.avatar_id
				},
				:buff_info => [],
				:army => attacker_army
			}
			attacker[:buff_info] << scroll.to_hash if scroll

			defender_name = nil
			dfender_type = nil
			if target_type == 1
				defender_name = target.player_name
			elsif target_type == 2
				defender_name = "Creeps"
				dfender_type = target.type
			elsif target_type == 3
				defender_name = target.owner_name
			end
			defender = {
				:owner_info => {
					:type => target.class.name,
					:id => target.id,
					:name => defender_name,
					:monster_type => target.type
				},
				:buff_info => [],
				:army => defender_army
			}

			defender[:owner_info][:avatar_id] = target.player.avatar_id if target.is_a?(Village)

			result = BattleModel.attack_calc(attacker, defender)
			
			# 如果进攻方获胜，计算奖励
			reward = {}
			if result[:winner] == 'attacker'
				reward = case target_type
				when BattleModel::TARGET_TYPE[:village]
					target_player = target.player
					rwd = {:wood => target_player.wood/10, :stone => target_player.stone/10, :gold_coin => target_player.gold_coin/10, :items => []}
					target_player.spend!(rwd) # The target lost resource
					self.player.receive!(rwd) # The winner receive resource
					i_cat = [1,2,3].sample
					i_type = Item.const[i_cat].keys.sample
					i_count = i_cat == 2 ? 99 : 1
					rwd[:items] << {:item_cat => i_cat, :item_type => i_type, :item_count => i_count}
					target.set(:under_attack, 0)
					rwd
				when BattleModel::TARGET_TYPE[:creeps]
					has_reward = Tool.rate(0.4)

					if has_reward
						if Tool.rate(0.25)
							reward = {
								:items => [{
									:item_cat => Item.categories[:food], 
									:item_type => Specialty.types.sample, 
									:item_count => target.reward[:food_count]
								}]
							}
						elsif Tool.rate(0.25)
							reward = {
								:wood => target.reward[:res_count],
								:stone => target.reward[:res_count]
							}
						elsif Tool.rate(0.125)
							reward = {
								:items => [{
									:item_cat => Item.categories[:egg], 
									:item_type => target.reward[:egg_type].sample, 
									:item_count => 1
								}]
							}
						elsif Tool.rate(0.125)
							reward = {
								:items => [{
									:item_cat => Item.categories[:scroll],
									:item_type => target.reward[:scroll_type].sample,
									:item_count => 1
								}]
							}
						end
					end
					
					player.del_temp_creeps(target.index)
					target.delete
					reward

				when BattleModel::TARGET_TYPE[:gold_mine]
					if target.type == GoldMine::TYPE[:normal]
						target.update :player_id => player.id, :under_attack => false
						rwd = {:wood => 1500, :stone => 1500, :gold_coin => 200, :items => []}
						i_cat = Item.categories.values.sample
						i_type = Item.const[i_cat].keys.sample
						i_count = i_cat == 1 ? 1 : 100
						rwd[:items] << {:item_cat => i_cat, :item_type => i_type, :item_count => i_count}
						rwd
					else
						unless player.league.nil?
							target.add_attacking_count(player.league_id)
							self.player.increase(:experience, 100)
							player.league_member_ship.increase(:contribution, 200)
						end
						{} # reward = {}
					end
				else
					{}
				end
				player.receive!(reward)
			end # End of winner reward

			# Check beginning guide
			if !player.beginning_guide_finished && !player.guide_cache['attack_monster']
				player.set :guide_cache, player.guide_cache.merge('attack_monster' => true)
			end
			
			result.merge!(:reward => reward)
			army.each do |dino|
				dino.set :is_attacking, 0
			end
			player.save_battle_report(self.id, result)
			self.dissolve!
		end
	end

	def dissolve!
		self.dinosaurs.each do |dino_id|
			dino = Dinosaur[dino_id]
			if dino
				dino.set :is_attacking, 0
			end
		end
		delete
	end

end
