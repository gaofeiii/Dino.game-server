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

	reference :player, Player

	def to_hash
		{
			:id => id,
			:dinosaurs => dinosaurs,
			:target_type => target_type,
			:target_id => target_id.to_i,
			:total_time => arrive_time - start_time,
			:time_pass => Time.now.to_i - start_time
		}
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
		if Time.now.to_i >= arrive_time
			army = dinosaurs.map do |dino_id|
				dino = Dinosaur[dino_id]
				if dino && dino.status > 0
					dino
				end
			end.compact
			army = army.blank? ? player.dinosaurs.to_a.select{|d| d.status > 0}[0, 5] : army

			attacker = {
				:owner_info => {
					:type => 'Player',
					:id => player_id.to_i
				},
				:buff_info => {},
				:army => army
			}

			defender = {
				:owner_info => {
					:type => target.class.name,
					:id => target.id
				},
				:buff_info => {},
				:army => target.defense_troops
			}

			result = BattleModel.attack_calc(attacker, defender)
			if result[:winner] = 'attacker'
				reward = case target_type
				when 1
					rwd = {:wood => 1000, :stone => 2000, :gold_coin => 100, :items => []}
					i_cat = Item.categories.sample
					i_type = Item.types(i_cat).sample
					i_count = i_cat == 1 ? 1 : 100
					rwd[:items] << {:item_cat => i_cat, :item_type => i_type, :item_count => i_count}
					rwd
				when 2
					target.delete
					rwd = {:wood => 1000, :stone => 1200, :gold_coin => 150, :items => []}
					i_cat = Item.categories.sample
					i_type = Item.types(i_cat).sample
					i_count = i_cat == 1 ? 1 : 100
					rwd[:items] << {:item_cat => i_cat, :item_type => i_type, :item_count => i_count}
					rwd
				when 3
					target.update :player_id => player.id
					rwd = {:wood => 1500, :stone => 1500, :gold_coin => 200, :items => []}
					i_cat = Item.categories.sample
					i_type = Item.types(i_cat).sample
					i_count = i_cat == 1 ? 1 : 100
					rwd[:items] << {:item_cat => i_cat, :item_type => i_type, :item_count => i_count}
					rwd
				else
					{}
				end
				player.receive!(reward)
			end
			result.merge!(:reward => reward)
			target.set :under_attack, 0 if !target.is_a?(Creeps)
			army.each do |dino|
				dino.set :is_attacking, 0
			end
			player.save_battle_report(arrive_time, result)
			self.delete
		end
	end

	def dissolve!
		delete
	end

end
