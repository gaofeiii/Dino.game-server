# Only included by Player model.
module DailyQuest
	module ClassMethods
		@@daily_quest_info = {
			:data => {}
		}

		def daily_quests_const
			if @@daily_quest_info[:data].blank?
				load_daily_quest!
			end
			@@daily_quest_info
		end

		def find_daily_quest_info_by_index(idx, locale = :en)
			if @@daily_quest_info[:data].blank?
				load_daily_quest!
			end

			reward = @@daily_quest_info[:data][idx]
			return {} if reward.blank?
			info = @@daily_quest_info[locale.to_sym][idx]
			return info.merge(reward)
		end

		# min = 0, max = nil, limit = nil, locale = :en
		def random_daily_quests_by_level_range(args = {})
			if @@daily_quest_info[:data].blank?
				load_daily_quest!
			end

			level = args[:level] || 1
			min = args[:min] || 0
			max = args[:max] || 9999
			limit = args[:limit]

			result_ids = []
			@@daily_quest_info[:data].each do |number, val|
				# break if limit && result_ids.size >= limit
					
				if val[:level] >= min && val[:level] <= max
					result_ids << number
				end
			end

			if limit.kind_of?(Integer)
				result_ids = result_ids.sample(limit)
			end
			result_ids
		end

		def get_daily_quests_info_by_ids(ids = [], locale = :en)
			ids.map do |i|
				find_daily_quest_info_by_index(i, locale)
			end
		end

		def get_single_daily_quest_data_by_index(idx)
			if @@daily_quest_info[:data].blank?
				load_daily_quest!
			end

			@@daily_quest_info[:data]
		end

		def load_daily_quest!
			@@daily_quest_info.clear
			@@daily_quest_info = {:data => {}}

			book = Roo::Excelx.new("#{Rails.root}/const/daily_quest.xlsx")

			# Read basic data
			book.default_sheet = 'data'
			3.upto(book.last_row).each do |i|
				number = book.cell(i, 'A').to_i
				level = book.cell(i, "B").to_i
				rwd_wood = book.cell(i, 'C').to_i
				rwd_stone = book.cell(i, 'D').to_i
				rwd_gold_coin = book.cell(i, 'E').to_i
				rwd_gem = book.cell(i, 'F').to_i

				# xp_reg = /^\d+(\.\d+)?\+\d+(\.\d+)?%$/ # Pattern: 300.0+25.0%
				# tmp_xp = book.cell(i, 'G').gsub(/\s/, '')

				rwd_xp = book.cell(i, 'G').to_i
				rwd_ext_xp = 0.0

				# if tmp_xp =~ xp_reg
				# 	tmp_str_arr = tmp_xp.split('+')
				# 	rwd_xp = tmp_str_arr.first.to_i
				# 	rwd_ext_xp = tmp_str_arr.second.to_f / 100
				# end

				rwd_item_cat = book.cell(i, 'i').to_i
				rwd_item_type = book.cell(i, 'j').to_i
				rwd_item_count = book.cell(i, 'k').to_i

				steps = book.cell(i, 'L').to_i

				reward = Hash.new
				%w(wood stone gold_coin gem item_cat item_type item_count xp ext_xp).each do |name|
					code = %Q(reward[name.to_sym] = rwd_#{name} if rwd_#{name} > 0)
					eval(code)
				end
				@@daily_quest_info[:data][number] ||= {:number => number, :level => level, :reward => reward, :total_steps => steps}
			end

			# Read languages description
			%w(en cn).each do |locale|
				book.default_sheet = locale
				2.upto(book.last_row).each do |i|
					number = book.cell(i, 'A').to_i
					desc = book.cell(i, 'B')
					@@daily_quest_info[locale.to_sym] ||= {}
					@@daily_quest_info[locale.to_sym][number] = {:goal => desc}
				end
			end
			@@daily_quest_info
		end # End of load_daily_quest!
	end
	
	module InstanceMethods
		module SingleQuestMethods

		end

		def find_quest_by_index(idx)
			self.daily_quest.each do |d_quest|
				if d_quest[:number] == idx
					return d_quest
				end
			end
		end

		def set_rewarded(idx)
			quest = find_quest_by_index(idx)
			if quest && quest[:total_steps] > quest[:finished_steps]
				quest[:rewarded] = true
			end
		end

		def update_daily_quest_status!
			self.daily_quest.each do |quest|
				case quest[:number] % 5
				when 1
					quest[:finished_steps] = self.daily_quest_cache[:kill_monsters]
				when 2
					quest[:finished_steps] = self.daily_quest_cache[:occupy_gold_mines]
				when 3
					quest[:finished_steps] = self.daily_quest_cache[:attack_players]
				when 4
					quest[:finished_steps] = self.daily_quest_cache[:win_match_game]
				when 0
					quest[:finished_steps] = self.daily_quest_cache[:win_honour_val]
				end
				if quest[:finished_steps] > quest[:total_steps]
					quest[:finished_steps] = quest[:total_steps]
				end
			end
			self.set :daily_quest, self.daily_quest.to_json
		end
		
		def reset_daily_quest
			if daily_quest_updated_time < Time.now.beginning_of_day.to_i

				self.daily_quest = []
				self.daily_quest_cache = {
					:kill_monsters 			=> 0,
					:occupy_gold_mines 	=> 0,
					:attack_players 		=> 0,
					:win_match_game 		=> 0,
					:win_honour_val 		=> 0
				}

				min = level - level % 5 - 1
				min = 1 if min < 0
				max = level
				new_quests_ids = self.class.random_daily_quests_by_level_range(:min => min, :max => max, :limit => 5)
				self.daily_quest = new_quests_ids.map do |q_id|
					q_info = self.class.find_daily_quest_info_by_index(q_id)
					{:number => q_id, :rewarded => false, :finished_steps => 0, :total_steps => q_info[:total_steps]}
				end

				self.daily_quest_updated_time = Time.now.to_i
				self.daily_quest
			end
		end

		def reset_daily_quest!
			if reset_daily_quest
				self.sets :daily_quest => daily_quest.to_json,
									:daily_quest_cache => daily_quest_cache.to_json,
									:daily_quest_updated_time => daily_quest_updated_time,
									:finish_daily_quest => 0
			end
		end

		def daily_quests_full_info
			self.daily_quest.map do |quest|
				info = self.class.find_daily_quest_info_by_index(quest[:number], self.locale)
				quest.merge(info)
			end
		end

		def clear_daily_quests
			self.daily_quest = []
			self.daily_quest_cache = {
				:kill_monsters 			=> 0,
				:occupy_gold_mines 	=> 0,
				:attack_players 		=> 0,
				:win_match_game 		=> 0,
				:win_honour_val 		=> 0
			}
			self.save
		end

		# Rewrite the "get" method of attribute.
		def daily_quest
			if @attributes[:daily_quest].kind_of?(Array)# && @attributes[:daily_quest].any?
				return @attributes[:daily_quest]
			else
				@attributes[:daily_quest] = if @attributes[:daily_quest].nil?
					[]
				else
					JSON(@attributes[:daily_quest]).map{|q| q.deep_symbolize_keys}
				end
				@attributes[:daily_quest].each do |a_quest|
					a_quest.extend(SingleQuestMethods)
				end
			end
		end

		# Rewrite the "get" method of attribute.
		def daily_quest_cache
			if @attributes[:daily_quest_cache].kind_of?(Hash)
				return @attributes[:daily_quest_cache]
			else
				@attributes[:daily_quest_cache] = if @attributes[:daily_quest_cache].nil?
					{}
				else
					JSON(@attributes[:daily_quest_cache]).deep_symbolize_keys
				end
			end
		end

		def save!
			self.daily_quest = daily_quest.to_json
			self.daily_quest_cache = daily_quest_cache.to_json if daily_quest_cache.is_a?(Hash)
			super
		end

		
	end
	
	def self.included(model)
		model.attribute :daily_quest
		model.attribute :daily_quest_cache
		model.attribute :finish_daily_quest,		Ohm::DataTypes::Type::Boolean
		model.class_eval do
			remove_method :daily_quest
			remove_method :daily_quest_cache
		end
		model.attribute :daily_quest_updated_time, Ohm::DataTypes::Type::Integer
		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end