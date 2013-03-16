module StatFormat
	TAB = "\t"
	
	def to_excel_string
		values.join(TAB)
	end

	def to_title
		keys.map!{|k| k.to_s.titlecase}.join(TAB)
	end

end

class Stat

	INIT_PLAYER_RESULT = {
		:time => 0,
		:total_count => 0,
		:en_count => 0,
		:cn_count => 0,
		:level_1 => 0,
		:level_2 => 0,
		:level_3 => 0,
		:level_4 => 0,
		:level_5 => 0,
		:level_6_10 => 0,
		:level_11_15 => 0,
		:level_16_20 => 0,
		:level_20plus => 0,
		:is_set_nickname => 0,
		:not_set_nickname => 0,
		:login_in_last_day => 0,
		:new_player_in_last_day => 0
	}.freeze

	INIT_ORDER_RESULT = {
		:time => 0,
		:receipt_count => 0,
		:valid_count => 0,
		:total_sale => 0.0
	}

	class << self
		
		def check_players
			now_time = Time.now.utc

			result = INIT_PLAYER_RESULT.dup.extend(StatFormat)
			result[:time] = now_time

			ids = Player.none_npc.ids

			result[:total_count] += ids.count

			ids.each do |player_id|
				player = Player.new(:id => player_id).gets(:level, :locale, :experience, :is_set_nickname, :last_login_time, :created_at)

				case player.locale
				when "cn"
					result[:cn_count] += 1
				else
					result[:en_count] += 1
				end

				case player.level
				when 1
					result[:level_1] += 1
				when 2
					result[:level_2] += 1
				when 3
					result[:level_3] += 1
				when 4
					result[:level_4] += 1
				when 5
					result[:level_5] += 1
				when 6..10
					result[:level_6_10] += 1
				when 11..15
					result[:level_11_15] += 1
				when 16..20
					result[:level_16_20] += 1
				else
					result[:level_20plus] += 1
				end

				if player.is_set_nickname
					result[:is_set_nickname] += 1
				else
					result[:not_set_nickname] += 1
				end

				result[:login_in_last_day] += 1 if player.last_login_time > now_time.beginning_of_day.to_i
				result[:new_player_in_last_day] += 1 if player.created_at > now_time.beginning_of_day.to_i
			end

			return result
		end

		def players_result_path
			Rails.root.join("log").join("players_result.txt")
		end

		def record_players_info
			result = check_players

			path = players_result_path
			is_empty = !File.exist?(path) || File.size(path) <= 0

			file = File.new(path, "a")

			file.puts(result.to_title) if is_empty
			file.puts(result.to_excel_string)

			file.close
		end

		def check_orders
			result = INIT_ORDER_RESULT.dup.extend(StatFormat)

			ids = AppStoreOrder.all.ids

			result[:time] = Time.now.utc
			result[:receipt_count] = ids.count

			ids.each do |order_id|
				order = AppStoreOrder.new(:id => order_id).gets(:product_id, :is_validated, :is_valid)

				if order.is_validated && order.is_valid && order.product_id.in?(Shopping.iap_product_ids)
					result[:valid_count] += 1
					result[:total_sale] += Shopping.find_iap_price_by_product_id(order.product_id).to_f
				end
			end
			result
		end

		def orders_result_path
			Rails.root.join("log").join("orders_result.txt")
		end

		def record_orders_info
			result = check_orders

			path = orders_result_path
			is_empty = !File.exist?(path) || File.size(path) <= 0

			file = File.new(path, "a")

			file.puts(result.to_title) if is_empty
			file.puts(result.to_excel_string)

			file.close
		end

		def record_all
			record_players_info
			record_orders_info
		end
		
	end

end