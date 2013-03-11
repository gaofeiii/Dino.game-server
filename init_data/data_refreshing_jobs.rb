puts "--- Data Refreshing... ---"

Player.update_all_battle_rank!
League.update_all_battle_rank!

puts "--- Add cronjobs ---"
Background.add_cronjob(WorldChat, 'clean_up!', 2.hours.to_i)
Background.add_cronjob(LeagueChat, 'clean_up!', 2.hours.to_i)
Background.add_cronjob(PrivateChat, 'clean_up!', 1.day.to_i)