#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application.rb"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

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
Background.add_cronjob('Ohm.redis', 'bgsave', 5.minutes)

while($running) do
  
  # Replace this with your code
  Rails.logger.auto_flushing = true
  Rails.logger.info "This daemon is still running at #{Time.now}.\n"

	Background.perform!
	LeagueWar.perform!
  
  sleep 10
end