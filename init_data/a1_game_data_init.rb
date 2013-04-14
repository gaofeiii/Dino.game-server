if Country.count <= 0
	puts '[Init Data] Initializing country and maps info ---'
	1.upto(1) do |i|
		country = Country.create :index => i
		country.init_new!
		country.create_gold_mines
	end
end

npcs = Player.find(:player_type => Player::TYPE[:npc]).to_a

if npcs.size < 1
	puts "[Init Data] Creating NPC Players ---"

	npcs = ["Scud", "Raptor", "Vampire", "Tyrant"].map do |name|
		Player.create(:nickname => name, :player_type => Player::TYPE[:npc], :avatar_id => rand(1..8), :level => 1)
	end

end

if AdvisorRecord.count < 1
	puts "[Init Data] Creating NPC Advisors record ---"

	npcs.each_with_index do |player, idx|
		AdvisorRecord.create :type => idx + 1, :price => 1000, :player_id => player.id
	end
end

military_record = AdvisorRecord.find(:type => 2).first

if military_record.player.is_npc? && military_record.player.dinosaurs.size < 1
	puts "[Init Data] Creating NPC dinosaur ---"

	npc_dino = Dinosaur.create_by(:type => 4, :player_id => military_record.player_id)
	npc_dino.set :experience, 2311 # Make level to 8
	npc_dino.update_level
	npc_dino.save
end

if Player.bill.blank?
	puts "[Init Data] Creating Bill Player ---"
	Player.create :nickname => "bill", :player_type => Player::TYPE[:bill], :avatar_id => 1, :level => 10
	Player.bill.village.set :protection_until, ::Time.now.to_i
end