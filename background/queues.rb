# This is independant from rails application, should load rails app first.
require File.expand_path("./config/environment.rb")
require 'daemons'

# NOTE: 在Block #{Daemons}使用roo读取电子表格会出现异常，故现在外层将游戏用到的常量信息读取到内存
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

Daemons.run_proc('Refreshing queues...') do
	loop do
		Troops.all.map { |tps| tps.refresh! }
		sleep(0.8)
	end
end
