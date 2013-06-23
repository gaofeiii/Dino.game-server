require File.expand_path("./config/environment.rb")

puts "--- RAILS_ENV: #{Rails.env} ---"

Ohm.redis.quit
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

require 'daemons'

options = {
	:app_name 	=> 'dinosaur_bgd',
  :backtrace  => true,
  :log_dir		=> "#{Rails.root}/log",
  :log_output => true
}

Daemons.run_proc('DS2-game-background-job', options) do
	loop do
		begin
			Background.perform!
			LeagueWar.perform!
		ensure
			sleep(1)
		end
	end
end