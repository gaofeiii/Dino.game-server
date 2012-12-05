class Advisor < Ohm::Model

	TAX = 0.01
	TYPES = {:produce => 1, :military => 2, :business => 3, :technology => 4}

	class << self
		def apply_advisor(player, prc)
			self.create :player_id => player.id, :price => prc
		end

		def types
			TYPES
		end

		def create_by_type_and_days(player_id, type, days = 1)
			return false unless type.to_i.in?(TYPES.values)

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
			end	
		end

		def find_random_by_type(type, count = 1)
			r_key = Advisor.key[:type][type]
			adv_ids = db.hkeys(r_key).sample(count)
			advs = db.hmget(r_key, adv_ids)

			result = []
			advs.each_with_index do |adv,idx|
				if adv.nil?
					next
				end

				name, lvl, days, avt_id = adv.split(":")
				result << {
					:nickname => name,
					:level => lvl.to_i,
					:days => days.to_i,
					:type => type,
					:price => [1000, 2800, 5600].sample,
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
			adv_info = info.split(':')
			{
				:nickname => adv_info[0],
				:level => adv_info[1],
				:days => adv_info[2],
				:avatar_id => adv_info[3]
			}
		end

		def clear_all!
			db.multi do |t|
				t.del(self.key[:type][1])
				t.del(self.key[:type][2])
				t.del(self.key[:type][3])
				t.del(self.key[:type][4])
			end
		end

		
	end
end
