class ToolBox
	def self.clean_with_log(&block)
		start_time = Time.now.to_f
		block.call
		puts "\n-- Work Done!!! Cost #{format("%.3f", Time.now.to_f - start_time)} seconds."
	end

	def self.log_in_loop(name, curr, total, cleaned = 0)
		if total >= 1000 && curr % 5 != 0 && curr != total
			return nil
		end

		puts "-- #{name}..." || "--- [No title]"
		STDOUT.write "\r* finished: #{curr}/#{total}(#{format("%.1f", curr/total.to_f*100)}%)\n* cleaned: #{cleaned}"
	end

	## Clean inactive players by time interval, params: time_interval
	#
	#  E.g, ToolBox.clean_player(3.months.ago)
	#
	def self.clean_player(time_interval)
		if time_interval.blank?
			raise "Should input time interval"
		end

		count = Player.none_npc.count
		cleaned = 0
		start_time = Time.now.to_f

		time = time_interval.to_i

		Player.none_npc.each_with_index do |player, i|
			if player.village.nil? || player.last_login_time < time
				unless player.level < 10 && player.app_store_orders.size == 0
					player.delete
					cleaned += 1
					STDOUT.write "\r--- Cleaned: #{cleaned} | Finished: #{i + 1}/#{count} (#{format("%.2f", (i+1)/count.to_f * 100)}%) ---"
				end
			end
		end

		Country.first.refresh_used_town_nodes

		puts "Done!!!"
		STDOUT.write "\r=== Clear #{cleaned} players. Spend #{format("%.3f", Time.now.to_f - start_time)} seconds. ==="
	end

	def self.clean_players
		count = Player.none_npc.count
		cleaned = 0

		start_time = Time.now.to_f

		Player.none_npc.each_with_index do |player, i|
			if player.village.nil?
				player.delete
				cleaned += 1
			elsif player.level < 3 && player.last_login_time < 2.weeks.ago.to_i && player.app_store_orders.count <= 0
				player.delete
				cleaned += 1
			elsif player.level >= 3 && player.level < 10 && player.last_login_time < 1.months.ago.to_i && player.app_store_orders.count <= 0
				player.delete
				cleaned += 1
			elsif player.level >= 10 && player.last_login_time < 3.months.ago.to_i && player.app_store_orders.count <= 0
				player.delete
				cleaned += 1
			end

			STDOUT.write "\r--- Cleaned: #{cleaned} | Finished: #{i + 1}/#{count} (#{format("%.2f", (i+1)/count.to_f * 100)}%) ---"
		end
	end

	# Clean all the invalid app store orders.
	def self.clean_iap
		count = AppStoreOrder.count
		cleaned = 0
		start_time = Time.now.to_f

		AppStoreOrder.all.each_with_index do |order, i|
			unless order.product_id =~ /com.dinosaur.gems/
				order.delete
				cleaned += 1
			end

			system('clear')
			STDOUT.write "\r--- Finished: #{i+1}/#{count} (#{format("%.2f", (i+1)/count.to_f*100)}%) ---"
		end

		puts "Done!!!"
		puts "=== Clear #{cleaned} orders. Spend #{format("%.3f", Time.now.to_f - start_time)} seconds. ==="
	end

	# Clean the monsters, params: count, default=1000
	def self.clean_monsters(count = 1000)
		clean_with_log do
			# count.times do |i|
			# 	Monster.first.delete
			# 	log_in_loop("Clean Monsters", i+1, count, i+1)
			# end

			key_array = Ohm.redis.srandmembers(Monster.all.key, count)
			real_count = key_array.count

			key_array.each_with_index do |id, index|
				Monster[id].try(:delete)
				log_in_loop("Clean Monsters", index+1, real_count, index+1)
			end
		end
	end

	# Clean the beginner, params: count, default=1000
	def self.clean_beginner_guide(count = 1000)
		clean_with_log do
			arr = Ohm.redis.srandmembers(BeginnerGuide.all.key, count)
			r_count = arr.count
			cleaned = 0

			arr.each_with_index do |kid, i|
				guide = BeginnerGuide[kid]
				if guide.player.blank?
					guide.delete
					cleaned += 1
				end
				log_in_loop('Cleaning beginner guides data', i+1, r_count, cleaned)
			end
		end
	end

	# Clean the serial tasks, params: count, default=1000
	def self.clean_serial_tasks(count = 1000)
		clean_with_log do
			arr = Ohm.redis.srandmembers(SerialTask.all.key, count)
			r_count = arr.count
			cleaned = 0

			arr.each_with_index do |kid, i|
				guide = SerialTask[kid]
				if guide.player.blank?
					guide.delete
					cleaned += 1
				end
				log_in_loop('Cleaning beginner guides data', i+1, r_count, cleaned)
			end
		end
	end

	def self.clean_all
		self.clean_player(3.months.ago)
		self.clean_iap
		self.clean_beginner_guide
		self.clean_monsters
		self.clean_serial_tasks
	end
end