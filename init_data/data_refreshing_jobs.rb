puts "--- Setting Server:status to 1... ---"

Ohm.redis.set('Server:status', 1)

# Player.update_all_battle_rank!
# League.update_all_battle_rank!

# puts "--- Adding system queues ---"

# puts "--- Adding cronjobs ---"
# Background.clear_all_cronjobs
# Background.add_cronjob(WorldChat, 'clean_up!', 2.hours.to_i)
# Background.add_cronjob(LeagueChat, 'clean_up!', 2.hours.to_i)
# Background.add_cronjob(PrivateChat, 'clean_up!', 1.day.to_i)
# Background.add_cronjob(Player, 'update_all_battle_rank!', 30.minutes.to_i)
# Background.add_cronjob(League, 'update_all_battle_rank!', 1.hour.to_i)
# Background.add_cronjob(LeagueWar, 'calc_battle_result', 	30.minutes.to_i)
# LeagueWar.start!
# Background.add_cronjob(Stat, 'record_all', 1.hour)
# Background.add_cronjob(Mail, 'clean_up!', 6.hours)
# Background.add_cronjob(Deal, 'clean_up!', 1.hour)
# Background.add_cronjob(AdvisorRelation, 'clean_up!', 1.hour)
# Background.add_cronjob(AdvisorRecord, 'clean_up!', 1.hour)
# Background.add_cronjob(GameMail, 'clean_up!', 6.hours)