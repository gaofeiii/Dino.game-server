puts "--- Data Refreshing... ---"

Player.update_all_battle_rank!
League.update_all_battle_rank!

puts "--- Adding system queues ---"

puts "--- Adding cronjobs ---"
Background.clear_all_cronjobs
# Background.add_cronjob(WorldChat, 'clean_up!', 2.hours.to_i)
# Background.add_cronjob(LeagueChat, 'clean_up!', 2.hours.to_i)
# Background.add_cronjob(PrivateChat, 'clean_up!', 1.day.to_i)
Background.add_cronjob(Player, 'update_all_battle_rank!', 1.hour.to_i)
Background.add_cronjob(League, 'update_all_battle_rank!', 1.hour.to_i)
Background.add_cronjob(LeagueWar, 'calc_battle_result', 	30.minutes.to_i)
LeagueWar.start!
Background.add_cronjob(Stat, 'record_all', 1.hour)
Background.add_cronjob(Mail, 'clean_up!', 6.hours)
Background.add_cronjob(AdviseRelation, 'clean_up!', 1.hours)
Background.add_cronjob(Deal, 'clean_up!', 1.hour)
Background.add_cronjob(GoldMine, 'refresh_all_players_goldmine', 1.hour)