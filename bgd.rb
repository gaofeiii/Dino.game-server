require File.expand_path("./config/environment.rb")

puts "--- RAILS_ENV: #{Rails.env} ---"

Dinosaur.const
Technology.const
Monster.const
Building.const
Player.daily_quests_const
String.load_sensitive_words!
Item.const
LuckyReward.load_const!
Player.load_exps!
Player.load_honour_const!
Shopping.list
Skill.const

puts "--- Adding cronjobs ---"
Background.clear_all_cronjobs(Ohm.redis)
Background.add_cronjob(WorldChat, 'clean_up!', 1.day.to_i)
Background.add_cronjob(LeagueChat, 'clean_up!', 1.day.to_i)
Background.add_cronjob(PrivateChat, 'clean_up!', 1.day.to_i)
Background.add_cronjob(Player, 'update_all_battle_rank!', 10.minutes.to_i)
Background.add_cronjob(League, 'update_all_battle_rank!', 10.minutes.to_i)
Background.add_cronjob(LeagueWar, 'calc_battle_result', 30.minutes.to_i)
LeagueWar.start!
Background.add_cronjob(Stat, 'record_all', 1.hour)
Background.add_cronjob(Mail, 'clean_up!', 6.hours)
Background.add_cronjob(Deal, 'clean_up!', 1.hour)
Background.add_cronjob(AdvisorRelation, 'clean_up!', 30.minutes)
Background.add_cronjob(AdvisorRecord, 'clean_up!', 30.minutes)
Background.add_cronjob(GameMail, 'clean_up!', 6.hours)
Background.add_cronjob(ToolBox, 'clean_all', 1.hour)

Background.add_cronjob('Ohm.redis', 'bgsave', 5)

require 'daemons'

options = {
	:app_name 	=> 'dinosaur_bgd',
 	:backtrace  => true,
 	:log_dir	=> "#{Rails.root}/log",
 	:log_output => true,
 	:monitor 	=> false
}

Ohm.redis.quit

Daemons.run_proc('DS-Refreshing', options) do
	loop do
		begin
			Background.perform!
			LeagueWar.perform!
		ensure
			sleep(1)
		end
	end
end