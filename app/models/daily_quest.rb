module DailyQuest
	module ClassMethods
		@@daily_quest_info = {
			:data => {}
		}

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

			book = Excelx.new("#{Rails.root}/const/daily_quest.xlsx")

			# Read basic data
			book.default_sheet = 'data'
			3.upto(book.last_row).each do |i|
				number = book.cell(i, 'A').to_i
				level = book.cell(i, "B").to_i
				rwd_wood = book.cell(i, 'C').to_i
				rwd_stone = book.cell(i, 'D').to_i
				rwd_gold_coin = book.cell(i, 'E').to_i
				rwd_gem = book.cell(i, 'F').to_i
				rwd_item_cat = book.cell(i, 'G').to_i
				rwd_item_type = book.cell(i, 'H').to_i
				rwd_item_count = book.cell(i, 'I').to_i

				steps = book.cell(i, 'J').to_i

				reward = Hash.new
				%w(wood stone gold_coin gem item_cat item_type item_count).each do |name|
					code = %Q(reward[name.to_sym] = rwd_#{name} if rwd_#{name} > 0)
					eval(code)
					# eval("reward[#{name.to_sym}] = rwd_#{name} if rwd_#{name} > 0")
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
		
		def update_daily_quest
			if daily_quest_updated_time < Time.now.beginning_of_day.to_i
				# DO update!!!
				self.daily_quest = []
				self.daily_quest_cache = {}

				new_quests_ids = self.class.random_daily_quests_by_level_range(:max => level, :limit => 5)
				self.daily_quest = new_quests_ids.map do |q_id|
					q_info = self.class.find_daily_quest_info_by_index(q_id)
					{:number => q_id, :rewarded => false, :finshed_steps => 0, :total_steps => q_info[:total_steps]}
				end

				self.daily_quest_updated_time = Time.now.to_i
				self.daily_quest
			end
		end

		def update_daily_quest!
			if update_daily_quest
				self.sets :daily_quest => daily_quest.to_json,
									:daily_quest_cache => daily_quest_cache.to_json
			end
		end

		def daily_quests_full_info
			self.daily_quest.map do |quest|
				info = self.class.find_daily_quest_info_by_index(quest[:number])
				quest.merge(info)
			end
		end

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

		def save!
			self.daily_quest = self.daily_quest.to_json
			super
		end

		
	end
	
	def self.included(model)
		model.attribute :daily_quest
		model.attribute :daily_quest_cache, Ohm::DataTypes::Type::Hash
		model.class_eval do
			remove_method :daily_quest
		end
		model.attribute :daily_quest_updated_time, Ohm::DataTypes::Type::Integer
		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end