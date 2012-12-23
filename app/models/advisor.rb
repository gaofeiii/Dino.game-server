class Advisor < Ohm::Model

	TAX = 0.0
	TYPES = {:produce => 1, :military => 2, :business => 3, :technology => 4}

	class << self
		def types
			TYPES
		end

		def is_advisor?(player_id)
			!Player.get(player_id, :is_advisor).to_i.zero?
		end

		def create_by_type_and_days(player_id, type, days = 1)
			return false unless type.to_i.in?(TYPES.values)
			player = Player.new :id => player_id
			player.get :player_type

			if is_advisor?(player_id)
				return false if player.player_type != Player::TYPE[:npc]
			end

			name, lvl, avatar_id = Player.gets(player_id, :nickname, :level, :avatar_id)
			type_key = Advisor.key[:type][type]

			db.multi do |t|
				t.hmset(type_key, player_id, "#{name}:#{lvl}:#{days}:#{avatar_id}")
				t.hmset(Player.key[player_id], :is_advisor, 1, :advisor_type, type)
			end
		end

		def cancel_apply(player_id)
			type = Player.gets(player_id, :advisor_type)
			db.multi do |t|
				t.hdel(Advisor.key[:type][type], player_id)
				t.hdel(Player.key[player_id], [:is_advisor, :advisor_type])
			end
		end

		def employ!(employer_id, advisor_id, type, days)
			if !db.hexists(Advisor.key[:type][type], advisor_id) || !TYPES.values.include?(type.to_i)
				return false
			end

			if AdviseRelation.create 	:type => type, 
																:start_time => ::Time.now.to_i, 
																:days => days,
																:advisor_id => advisor_id,
																:employer_id => employer_id
				advisor = Player.new(:id => advisor_id)
				advisor.get :player_type
				db.multi do |t|
					t.hdel(Advisor.key[:type][type], advisor_id) if !advisor.is_npc?
					t.hmset("Player:#{advisor_id}", :is_advisor, 1, :is_hired, 1)
				end
			end	
		end
		alias hire! employ!

		def fire!(employer_id, advisor_id)
			relation = AdviseRelation.with(:advisor_id, advisor_id)
			if relation.delete
				db.hdel("Player:#{advisor_id}", [:is_advisor, :is_hired])
			end
		end

		# TODO: Advisor price.
		def hire_price(level, days)
			factor = if days >= 7
				0.9
			elsif days < 7 && days >= 3
				0.95
			else
				1
			end
			((level ** 1.2).to_i * 500 * days * factor).to_i
		end

		def find_random_by_type(type, count = 1)
			r_key = Advisor.key[:type][type]
			adv_ids = db.hkeys(r_key).sample(count)

			if adv_ids.empty?
				return []
			end

			advs = db.hmget(r_key, adv_ids)

			result = []
			advs.each_with_index do |adv, idx|
				if adv.nil?
					next
				end

				name, lvl, days, avt_id = adv.split(":")
				level = lvl.to_i
				ds = days.to_i
				result << {
					:nickname => name,
					:level => level,
					:days => ds,
					:type => type,
					:price => hire_price(level, ds),
					:avatar_id => avt_id.to_i,
					:player_id => adv_ids[idx].to_i
				}
			end
			return result
		end

		# adv_info:
		# => [name, level, days, avatar_id]
		def get(type, player_id)
			r_key = Advisor.key[:type][type]
			info = db.hget(r_key, player_id)
			return nil if info.nil?
			name, lvl, ds, avatar_id = info.split(':')
			lvl = lvl.to_i
			ds = ds.to_i
			avatar_id = avatar_id.to_i
			{
				:nickname => name,
				:level => lvl,
				:days => ds,
				:avatar_id => avatar_id,
				:price => hire_price(lvl, ds)
			}
		end

		def clear_all!
			db.del(self.key[:type][1])
			db.del(self.key[:type][2])
			db.del(self.key[:type][3])
			db.del(self.key[:type][4])
			Player.all.ids.each do |ids|
				db.hdel("Player:#{ids}", [:is_hired, :is_advisor])
			end
		end

		
	end
end
