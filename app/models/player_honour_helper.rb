module PlayerHonourHelper
	HONOUR_BATTLE_COUNT = 20

	module ClassMethods
		@@honour_scores_asc = Array.new
		@@honour_scores_desc = Array.new
		@@honour_gold_cost = Array.new

		
		def load_honour_const!
			@@honour_scores_asc.clear
			@@honour_scores_desc.clear
			@@honour_gold_cost = [0]
			book = Roo::Excelx.new "#{Rails.root}/const/honour_match.xlsx"

			book.default_sheet = "calc"
			2.upto(book.last_row) do |i|
				@@honour_scores_asc  << book.cell(i, 'e').to_i
				@@honour_scores_desc << book.cell(i, 'f').to_i
			end

			book.default_sheet = "gold"
			2.upto(book.last_row) do |i|
				@@honour_gold_cost << book.cell(i, 'b').to_i
			end
		end

		def honour_gold_cost
			if @@honour_gold_cost.blank?
				load_honour_const!
			end
			@@honour_gold_cost
		end

		def honour_scores_asc
			if @@honour_scores_asc.blank?
				load_honour_const!
			end
			@@honour_scores_asc
		end

		def honour_scores_desc
			if @@honour_scores_desc.blank?
				load_honour_const!
			end
			@@honour_scores_desc
		end

		def calc_score(x, y)
			dis = x - y
			if dis > 0
				honour_scores_desc[dis]
			else
				honour_scores_asc[-dis]
			end
		end
	end
	
	module InstanceMethods
		
		def save!
			self.honour_strategy = honour_strategy.to_json
			super
		end

		def honour_strategy
			if @attributes[:honour_strategy].blank?
				@attributes[:honour_strategy] = Array.new(5, -1)
				return @attributes[:honour_strategy]
			end

			if @attributes[:honour_strategy].is_a?(Array)
				return @attributes[:honour_strategy]
			end

			if @attributes[:honour_strategy].is_a?(String)
				@attributes[:honour_strategy] = JSON(@attributes[:honour_strategy].to_s)
			end
			@attributes[:honour_strategy] = Array.new(5, -1) if @attributes[:honour_strategy].blank?
			@attributes[:honour_strategy]
		end

		def match_cost
			{:gold => self.class.honour_gold_cost[level]}
		end

		def todays_count
			if self.honour_refresh_time < Time.now.beginning_of_day.to_i
				self.sets(:honour_refresh_time => Time.now.to_i, :honour_battle_count => total_honour_count)
			end
			self.honour_battle_count
		end

		def total_honour_count
			is_vip? ? 30 : 20
		end

		def desr_honour_battle_count(count = 1)
			self.increase :honour_battle_count, -count
		end

		def add_honour(count)
			self.increase(:honour_score, count)
		end

		def dec_honour(count)
			if self.honour_score - count <= 0
				self.set :honour_score, 0
			else
				self.increase(:honour_score, -count)
			end
		end

		def has_set_honour_strategy?
			honour_strategy.each do |dino_id|
				return true if Dinosaur.exists?(dino_id)
			end
			
			false
		end

	end
	
	def self.included(model)
		model.attribute :honour_score, Ohm::DataTypes::Type::Integer
		model.attribute :honour_strategy
		model.class_eval do
			remove_method :honour_strategy
		end
		model.attribute :honour_battle_count, Ohm::DataTypes::Type::Integer # 用户记录当天挑战的次数
		model.attribute :honour_refresh_time, Ohm::DataTypes::Type::Integer

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end