class ToolBox

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
				player.delete
				cleaned += 1
			end

			system('clear')
			puts "--- Cleaned: #{cleaned} | Finished: #{i + 1}/#{count} (#{format("%.2f", (i+1)/count.to_f * 100)}%) ---"
		end

		Country.first.refresh_used_town_nodes

		puts "Done!!!"
		puts "=== Clear #{cleaned} players. Spend #{format("%.3f", Time.now.to_f - start_time)} seconds. ==="
	end

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
			puts "--- Finished: #{i+1}/#{count} (#{format("%.2f", (i+1)/count.to_f*100)}%) ---"
		end

		puts "Done!!!"
		puts "=== Clear #{cleaned} orders. Spend #{format("%.3f", Time.now.to_f - start_time)} seconds. ==="
	end


end