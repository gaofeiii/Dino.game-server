require File.expand_path("./config/environment.rb")

puts "--- RAILS_ENV: #{Rails.env} ---"

Ohm.redis.quit
Dinosaur.const
Technology.const
Monster.const
Building.const
Advisor.const
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
  :log_dir		=> "#{Rails.root}/tmp",
  :log_output => true
}

Daemons.run_proc('Refreshing', options) do
	loop do
		begin
			Background.perform!
		ensure
			sleep(1)
		end
	end
end