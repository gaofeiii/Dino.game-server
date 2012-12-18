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
					:id => player_id
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
				case target_type
				when 1

				when 2
					target.delete
				when 3
					target.update :player_id => player.id
				end
			end
			player.save_battle_report(Time.now.to_i, result)
			self.delete
		end
	end

	def dissolve!
		delete
	end

end
