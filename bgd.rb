require 'daemons'
require File.expand_path("./config/environment.rb")
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

options = {
	:app_name 	=> 'dinosaur_bgd',
  :backtrace  => true,
  :log_dir		=> "#{Rails.root}/tmp",
  :log_output => true
}

Daemons.run_proc('Refreshing', options) do
	p "starting loop..."
	loop do
		begin
			p 'run Background.perform!'
			Background.perform!
		ensure
			sleep(1)
		end
	end
end