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
			puts "--- Cleaned: #{cleaned} | Finished: #{i + 1}/#{count} (#{format("%.2f", (i+1)/count.to_f)}%) ---"
		end

		puts "Done!!!"
		puts "=== Spend #{format("%.3f", Time.now.to_f - start_time)} seconds. ==="
	end
end