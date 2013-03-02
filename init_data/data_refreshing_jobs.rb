puts "--- Data Refreshing... ---"

Player.update_all_battle_rank!
League.update_all_battle_rank!