module KillBillQuest
	module ClassMethods
		@@bill_quests = {
			:data => {},
			:cn => {},
			:en => {}
		}

		def bill_quests
			if @@bill_quests[:data].blank?
				load_bill!
			end
			@@bill_quests
		end
		
		def load_bill!
			puts "--- Reading bill ---"
			@@bill_quests = { :data => {}, :cn => {}, :en => {} }

			book = Roo::Excelx.new "#{Rails.root}/const/kill_bill.xlsx"

			# === Reading quest data ===
			book.default_sheet = 'data'
			3.upto(book.last_row).each do |i|
				number = book.cell(i, 'A').to_i
				monst_level = book.cell(i, 'B').to_i
				monst_num = book.cell(i, 'C').to_i
				monst_gold = book.cell(i, 'E').to_i

				rwd_cat = book.cell(i, 'I').to_i
				rwd_type = book.cell(i, 'J').to_i
				rwd_count = book.cell(i, 'K').to_i
				egg_quality = book.cell(i, 'L').to_i
				player_exp = book.cell(i, 'N').to_i

				@@bill_quests[:data][number] = {
					:number => number,
					:monst_level => monst_level,
					:monst_num => monst_num,
					
					:reward => {
						:item_cat => rwd_cat,
						:item_type => rwd_type,
						:item_count => rwd_count,
						:xp => player_exp,
						:egg_quality => egg_quality,
						:gold_coin => monst_gold,
					},
					:total_steps => 1
				}
			end

			# === Reading cn description ===
			book.default_sheet = 'cn'
			2.upto(book.last_row) do |i|
				number = book.cell(i, "A").to_i
				desc = book.cell(i, 'B')

				@@bill_quests[:cn][number] = desc
			end

			# === Reading cn description ===
			book.default_sheet = 'en'
			2.upto(book.last_row) do |i|
				number = book.cell(i, "A").to_i
				desc = book.cell(i, 'B')

				@@bill_quests[:en][number] = desc
			end
		end

		def bill_monsters(index)
			quest = bill_quests[:data][index]
			quest.slice(:monst_level, :monst_num) if quest
		end
	end
	
	module InstanceMethods
		def kill_bill_quests
			if @attributes[:kill_bill_quests].nil?
				@attributes[:kill_bill_quests] = []
			elsif @attributes[:kill_bill_quests].is_a?(String)
				@attributes[:kill_bill_quests] = JSON(@attributes[:kill_bill_quests])
				@attributes[:kill_bill_quests].map!{|q| q.deep_symbolize_keys}
			end

			return @attributes[:kill_bill_quests]
		end

		def save!
			self.kill_bill_quests = kill_bill_quests.to_json
			super
		end
		
		def curr_bill_quest
			if kill_bill_quests.blank?
				quest = self.class.bill_quests[:data].values.first
				self.kill_bill_quests << {
					:number => quest[:number],
					:rewarded => false,
					:finished_steps => 0, 
					:total_steps => quest[:total_steps]
				}
			else
				last_bill_quest = kill_bill_quests.last

				if last_bill_quest[:rewarded]
					new_quest = self.class.bill_quests[:data][last_bill_quest[:number] + 1]

					return nil unless new_quest

					self.kill_bill_quests << {
						:number => new_quest[:number],
						:rewarded => false,
						:finished_steps => 0, 
						:total_steps => new_quest[:total_steps]
					}
				end
			end
			kill_bill_quests.last
		end # End of curr_bill_quest
	end

	def curr_bill_quest_full_info
		curr = curr_bill_quest

		if curr
			const_info = self.class.bill_quests[:data][curr[:number]]
			desc = self.class.bill_quests[locale.to_sym][curr[:number]]
			curr.merge 	:goal => desc,
									:level => const_info[:monst_level],
									:reward => const_info[:reward],
									:x => Player.bill_village.x,
									:y => Player.bill_village.y
		end
	end

	def receive_bill_reward!(reward)
		self.receive!(reward)
		self.earn_exp!(reward[:xp]) if reward.has_key?(:xp)

		if reward[:item_cat]
			if reward[:item_cat] == Item.categories[:food]
				receive_food!(reward[:item_type], reward[:item_count])
			else
				Item.create(:item_category => reward[:item_cat], :item_type => reward[:item_type], :quality => reward[:egg_quality], :player_id => id)
			end
		end
	end

	def get_bill_reward
		curr = curr_bill_quest

		if curr[:finished_steps] >= curr[:total_steps]
			return if curr[:rewarded] == true

			reward = self.class.bill_quests[:data][curr[:number]][:reward]
			self.receive_bill_reward!(reward)
			curr[:rewarded] = true
			self.set :kill_bill_quests, kill_bill_quests.to_json
		end
	end
	
	def self.included(model)
		model.attribute :kill_bill_quests

		model.class_eval do
			remove_method :kill_bill_quests
		end

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end