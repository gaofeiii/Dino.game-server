if Player.find(:player_type => Player::TYPE[:npc]).size < 1
	puts "***** Creating NPC Players *****"
	players = 4.times.map do
		Player.create(:nickname => "NPC", :player_type => Player::TYPE[:npc], :avatar_id => rand(1..8), :level => 10)
	end

	players.each_with_index do |player, idx|
		Advisor.create_by_type_and_days(player.id, idx + 1, 1)
	end
end