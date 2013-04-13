if Country.count <= 0
	puts '--- Initializing country and maps info ---'
	1.upto(1) do |i|
		country = Country.create :index => i
		country.init_new!
		country.create_gold_mines
	end
end

players = Player.find(:player_type => Player::TYPE[:npc]).to_a
if players.size < 1
	puts "--- Creating NPC Players ---"
	players = 4.times.map do
		Player.create(:nickname => "NPC", :player_type => Player::TYPE[:npc], :avatar_id => rand(1..8), :level => 1)
	end

	players.each_with_index do |player, idx|
		AdvisorRecord.create :type => idx + 1, :price => 1000, :player_id => player.id
	end
end

if Player.bill.blank?
	Player.create :nickname => "bill", :player_type => Player::TYPE[:bill], :avatar_id => 1, :level => 10
	Player.bill.village.set :protection_until, ::Time.now.to_i
end