module SerialTaskConditionHelper
	
	def check!
		return true if finished

		@player = self.player

		ret = false

		case index
		when 20001 # 建造木材厂
			ret = @player.has_built?(Building.hashes[:lumber_mill])
			self.set :finished_steps, 1 if ret
		when 20002 # 建造采石场
			ret = @player.has_built?(Building.hashes[:quarry])
			self.set :finished_steps, 1 if ret
		when 20003 # 建造采集场
			ret = @player.has_built?(Building.hashes[:collecting_farm])
			self.set :finished_steps, 1 if ret
		when 20004 # 建造狩猎场
			ret = @player.has_built?(Building.hashes[:hunting_field])
			self.set :finished_steps, 1 if ret
		when 20005 # 攻占金矿
			ret = @player.serial_tasks_data[:occupy_gold_mines].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20006 # 升级金矿
			ret = @player.serial_tasks_data[:upgrade_goldmine].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20007 # 挑战擂台
			ret = @player.serial_tasks_data[:win_match_game].to_i >= 1
			self.set :finished_steps, 1 if ret#(ret ? 1 : @player.serial_tasks_data[:win_match_game])
		when 20008 # 加入或建立部落
			ret = !!@player.league_id
			self.set :finished_steps, 1 if ret
		when 20009 # 攻占部落金矿
			ret = @player.serial_tasks_data[:occupy_league_gold_mines].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20010 # 捐献部落
			ret = @player.serial_tasks_data[:donate_league].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20011 # 偷窃玩家的蔬菜
			ret = @player.serial_tasks_data[:steal_friend].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20012 # 掠夺一次玩家的村落
			ret = @player.serial_tasks_data[:attack_players].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20013 # 使用卷轴
			ret = @player.serial_tasks_data[:use_scroll].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20014 # 完全探索第6个巢穴
			cave = @player.caves.find(:index => 6).first
			ret = !!cave && cave.stars > 0
			self.set :finished_steps, (ret ? 6 : @player.caves.size)
		when 20015 # 恐龙蛋注灵
			ret = @player.serial_tasks_data[:egg_evolution].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20016 # 恐龙训练
			ret = @player.serial_tasks_data[:trained_dino].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20017 # 升级一座金矿到3级
			ret = @player.serial_tasks_data[:egg_evolution].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20018 # 抢占一座3级或以上的金矿
			ret = @player.serial_tasks_data[:upgrade_goldmine].to_i >= 3
			self.set :finished_steps, 1 if ret
		when 20018 # 抢占一座3级或以上的金矿
			ret = @player.serial_tasks_data[:attack_level_3_mine].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20019 # 请成为一个顾问
			ret = @player.serial_tasks_data[:being_advisor].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20020 # 出售货物
			ret = @player.serial_tasks_data[:sell_goods].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20021 # 获得一只霸王龙
			ret = @player.dinosaurs.find(:type => 9).any?
			self.set :finished_steps, 1 if ret
		when 20022 # 探索10个巢穴
			cave_size = @player.caves.size
			ret = cave_size - 1 >= 10 # The last one is unfinished
			self.set :finished_steps, (ret ? 10 : cave_size - 1)
		when 20023 # 探索20个巢穴
			cave_size = @player.caves.size
			ret = cave_size - 1 >= 20 # The last one is unfinished
			self.set :finished_steps, (ret ? 20 : cave_size - 1)
		when 20024 # 探索30个巢穴
			cave_size = @player.caves.size
			ret = cave_size - 1 >= 30 # The last one is unfinished
			self.set :finished_steps, (ret ? 30 : cave_size - 1)
		when 20025 # 探索40个巢穴
			cave_size = @player.caves.size
			ret = cave_size - 1 >= 40 # The last one is unfinished
			self.set :finished_steps, (ret ? 40 : cave_size - 1)
		when 20026 # 探索50个巢穴
			cave_size = @player.caves.size
			ret = cave_size - 1 >= 50 # The last one is unfinished
			self.set :finished_steps, (ret ? 50 : cave_size - 1)
		when 20027 # 探索60个巢穴
			cave_size = @player.caves.size
			ret = cave_size - 1 >= 60 # The last one is unfinished
			self.set :finished_steps, (ret ? 60 : cave_size - 1)
		when 20028 # 探索70个巢穴
			cave_size = @player.caves.size
			ret = cave_size - 1 >= 70 # The last one is unfinished
			self.set :finished_steps, (ret ? 70 : cave_size - 1)
		when 20029 # 探索80个巢穴
			cave_size = @player.caves.size
			ret = cave_size - 1 >= 80 # The last one is unfinished
			self.set :finished_steps, (ret ? 80 : cave_size - 1)
		when 20030 # 探索90个巢穴
			cave_size = @player.caves.size
			ret = cave_size - 1 >= 90 # The last one is unfinished
			self.set :finished_steps, (ret ? 90 : cave_size - 1)
		when 20031 # 探索完所有巢穴
			cave_size = @player.caves.size
			ret = cave_size >= 96 # The last one is unfinished
			self.set :finished_steps, (ret ? 90 : cave_size - 1)
		when 20032 # 累计掠夺10次玩家
			ret = @player.serial_tasks_data[:attack_players].to_i >= 10
			self.set :finished_steps, (ret ? 10 : @player.serial_tasks_data[:attack_players].to_i)
		when 20033 # 累计掠夺50次
			ret = @player.serial_tasks_data[:attack_players].to_i >= 50
			self.set :finished_steps, (ret ? 50 : @player.serial_tasks_data[:attack_players].to_i)
		when 20034 # 累计掠夺100次玩家
			ret = @player.serial_tasks_data[:attack_players].to_i >= 100
			self.set :finished_steps, (ret ? 100 : @player.serial_tasks_data[:attack_players].to_i)
		when 20035 # 累计掠夺1000次玩家
			ret = @player.serial_tasks_data[:attack_players].to_i >= 1000
			self.set :finished_steps, (ret ? 1000 : @player.serial_tasks_data[:attack_players].to_i)
		when 20036 # 累计抢夺1000金子
			ret = @player.serial_tasks_data[:rob_gold].to_i >= 1000
			self.set :finished_steps, (ret ? 1000 : @player.serial_tasks_data[:rob_gold].to_i)
		when 20037 # 累计抢夺10000金子
			ret = @player.serial_tasks_data[:rob_gold].to_i >= 10000
			self.set :finished_steps, (ret ? 10000 : @player.serial_tasks_data[:rob_gold].to_i)
		when 20038 # 累计抢夺100000金子
			ret = @player.serial_tasks_data[:rob_gold].to_i >= 100000
			self.set :finished_steps, (ret ? 100000 : @player.serial_tasks_data[:rob_gold].to_i)
		when 20039 # 累计抢夺1000000金子
			ret = @player.serial_tasks_data[:rob_gold].to_i >= 1000000
			self.set :finished_steps, (ret ? 1000000 : @player.serial_tasks_data[:rob_gold].to_i)
		when 20040 # 孵化出1只紫色恐龙
			ret = @player.serial_tasks_data[:hatch_purple_dino].to_i >= 1
			self.set :finished_steps, 1 if ret
		when 20041 # 孵化出3只紫色恐龙
			ret = @player.serial_tasks_data[:hatch_purple_dino].to_i >= 3
			self.set :finished_steps, @player.serial_tasks_data[:hatch_purple_dino].to_i
		when 20042 # 孵化出5只紫色恐龙
			ret = @player.serial_tasks_data[:hatch_purple_dino].to_i >= 5
			self.set :finished_steps, @player.serial_tasks_data[:hatch_purple_dino].to_i
		when 20043 # 孵化出7只紫色恐龙
			ret = @player.serial_tasks_data[:hatch_purple_dino].to_i >= 7
			self.set :finished_steps, @player.serial_tasks_data[:hatch_purple_dino].to_i
		when 20044 # 孵化出10只紫色恐龙
			ret = @player.serial_tasks_data[:hatch_purple_dino].to_i >= 10
			self.set :finished_steps, @player.serial_tasks_data[:hatch_purple_dino].to_i
		when 20045 # 孵化出1只橙色恐龙
			ret = @player.serial_tasks_data[:hatch_orange_dino].to_i >= 1
			self.set :finished_steps, @player.serial_tasks_data[:hatch_orange_dino].to_i
		when 20046 # 培育出一只5级的恐龙
			ret = @player.serial_tasks_data[:max_dino_level].to_i >= 5
			self.set :finished_steps, @player.serial_tasks_data[:max_dino_level].to_i
		when 20047 # 培育出一只10级的恐龙
			ret = @player.serial_tasks_data[:max_dino_level].to_i >= 10
			self.set :finished_steps, @player.serial_tasks_data[:max_dino_level].to_i
		when 20048 # 培育出一只15级的恐龙
			ret = @player.serial_tasks_data[:max_dino_level].to_i >= 15
			self.set :finished_steps, @player.serial_tasks_data[:max_dino_level].to_i
		when 20049 # 培育出一只30级的恐龙
			ret = @player.serial_tasks_data[:max_dino_level].to_i >= 30
			self.set :finished_steps, @player.serial_tasks_data[:max_dino_level].to_i
		when 20050 # 培育出一只60级的恐龙
			ret = @player.serial_tasks_data[:max_dino_level].to_i >= 60
			self.set :finished_steps, @player.serial_tasks_data[:max_dino_level].to_i
		when 20051 # 培育出一只90级的恐龙
			ret = @player.serial_tasks_data[:max_dino_level].to_i >= 90
			self.set :finished_steps, @player.serial_tasks_data[:max_dino_level].to_i
		when 20052 # 1项科技达到3级
			ret = @player.serial_tasks_data[:max_tech_level].to_i >= 3
			self.set :finished_steps, @player.serial_tasks_data[:max_tech_level].to_i
		when 20053 # 1项科技达到5级
			ret = @player.serial_tasks_data[:max_tech_level].to_i >= 3
			self.set :finished_steps, @player.serial_tasks_data[:max_tech_level].to_i
		when 20054 # 1项科技达到10级
			ret = @player.serial_tasks_data[:max_tech_level].to_i >= 3
			self.set :finished_steps, @player.serial_tasks_data[:max_tech_level].to_i
		when 20055 # 1项科技达到15级
			ret = @player.serial_tasks_data[:max_tech_level].to_i >= 3
			self.set :finished_steps, @player.serial_tasks_data[:max_tech_level].to_i
		when 20056 # 5项科技达到10级
			reached_techs_size = @player.techs.select{|t| t.level >= 10}.size
			ret = reached_techs_size >= 5
			self.set :finished_steps, reached_techs_size
		when 20057 # 5项科技达到15级
			reached_techs_size = @player.techs.select{|t| t.level >= 15}.size
			ret = reached_techs_size >= 5
			self.set :finished_steps, reached_techs_size
		when 20058 # 5项科技达到20级
			reached_techs_size = @player.techs.select{|t| t.level >= 20}.size
			ret = reached_techs_size >= 5
			self.set :finished_steps, reached_techs_size
		when 20059 # 10项科技达到15级
			reached_techs_size = @player.techs.select{|t| t.level >= 15}.size
			ret = reached_techs_size >= 10
			self.set :finished_steps, reached_techs_size
		when 20060 # 10项科技达到20级
			reached_techs_size = @player.techs.select{|t| t.level >= 20}.size
			ret = reached_techs_size >= 10
			self.set :finished_steps, reached_techs_size
		when 20061 # 15项科技达到15级
			reached_techs_size = @player.techs.select{|t| t.level >= 15}.size
			ret = reached_techs_size >= 15
			self.set :finished_steps, reached_techs_size
		when 20062 # 15项科技达到20级
			reached_techs_size = @player.techs.select{|t| t.level >= 20}.size
			ret = reached_techs_size >= 15
			self.set :finished_steps, reached_techs_size
		else
			false
		end # End of 'ret = case...'

		self.set :finished, 1 if ret

	end # End of 'def check!...'

end # End of 'module SerialTaskConditionHelper...'