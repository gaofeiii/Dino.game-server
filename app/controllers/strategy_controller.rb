class StrategyController < ApplicationController

	# before_filter :validate_village, :only => []
	before_filter :validate_player, :only => [:attack, :get_battle_report, :refresh_battle, :match_players, 
		:match_attack, :set_match_strategy, :league_goldmine_attack, :give_up_goldmine]

	def set_defense
		# Determine the target
		village = Village[params[:village_id]]
		gold_mine = GoldMine[params[:gold_mine_id]]

		target = village || gold_mine

		if target.nil?
			render_error(Error::NORMAL, "NO_TARGET_TO_DEPLOY") and return
		end

		# Find or make Strategy object
		@sta = target.strategy

		if @sta.nil?
			@sta = Strategy.create(:player_id => target.player_id)
			target.set :strategy_id, @sta.id
		end

		# Validate dinosaur ids
		valid_dinos = params[:dinosaurs].map do |dino_id|
			next if dino_id <= 0

			if not Dinosaur.exists?(dino_id)
				render_error(Error::NORMAL, I18n.t('strategy_error.dino_not_exist')) and return
			end

			dino_id
		end.compact

		# Determine the deployed dinosaurs' status
		dino_status = Dinosaur::ACTION_STATUS[:idle]
		if target.is_a?(Village)
			@sta.village_id = target.id
			dino_status = Dinosaur::ACTION_STATUS[:deployed]
		elsif target.is_a?(GoldMine)
			@sta.gold_mine_id = target.id
			dino_status = Dinosaur::ACTION_STATUS[:deployed_gold]
		end

		# Set the dinosaurs' ids to strategy object
		@sta.change_defense(params[:dinosaurs], dino_status)

		# Check if has scroll
		scroll = Item[params[:scroll_id]]
		@sta.set :scroll_id, scroll.id if scroll

		# Check beginner guide task
		@player = target.player || Dinosaur[valid_dinos.sample].player
		if @player && @player.has_beginner_guide?
			@player.cache_beginner_data(:has_set_defense => true)
		end

		# Render result
		data = {}
		if target.is_a?(Village)
			data = {:player => {:village => {:strategy => @sta.to_hash}}}
		elsif target.is_a?(GoldMine)
			data = {:info => "SUCCESS", :player => @player.to_hash}	
		end
		render_success(data)
	end

	def attack
		# 读取target信息
		target = if params[:village_id]
			Village[params[:village_id]]
		elsif params[:gold_mine_id]
			GoldMine[params[:gold_mine_id]]
		elsif params[:creeps_id]
			creeps_info = @player.temp_creeps(params[:creeps_id])
			if creeps_info.nil?
				nil
			else
				Creeps.create(creeps_info.except('guide_creeps'))
			end
		else
			nil
		end

		# 验证target信息
		if target.blank?
			render_error(Error::NORMAL, "INVALID_TARGET") and return
		end

		if target.is_a?(Village)
			if target.player_id.to_i == @player.id
				render_error(Error::NORMAL, I18n.t('strategy_error.cannot_attack_self_village')) and return
			end

			if @player.friends.ids.include?(target.player_id)
				render_error(Error::NORMAL, I18n.t('strategy_error.cannot_attack_friend_village')) and return
			end

			if target.under_protection
				render_error(Error::NORMAL, I18n.t('strategy_error.village_under_protection')) and return
			end

			if target.in_dangerous_area? && !LeagueWar.can_fight_danger_village?
				render_error(Error::NORMAL, I18n.t('strategy_error.cannot_attack_when_league_started')) and return
			end
		end

		if target.is_a?(GoldMine)
			if @player.friends.ids.include?(target.player_id)
				render_error(Error::NORMAL, I18n.t('strategy_error.cannot_attack_friend_goldmine')) and return
			end

			if target.type == GoldMine::TYPE[:normal]				
				render_error(Error::NORMAL, I18n.t('strategy_error.cannot_attack_self_goldmine')) and return if target.player_id.to_i == @player.id
				render_error(Error::NORMAL, I18n.t('strategy_error.reach_gold_mine_max')) and return if @player.gold_mines.size >= @player.curr_goldmine_size
				
			elsif target.type == GoldMine::TYPE[:league] 
				if @player.league_id.blank?
					render_error(Error::NORMAL, I18n.t('strategy_error.not_in_a_league')) and return
				elsif not LeagueWar.in_period_of_fight?
					render_error(Error::NORMAL, I18n.t('strategy_error.league_war_not_started', :time => LeagueWar.time_left / 60)) and return
				end
			end
		end

		if target.is_a?(Creeps)
			if target.under_attack
				render_error(Error::NORMAL, I18n.t('strategy_error.target_under_attack')) and return
			end
		end

		# 获取并验证出征军队的信息
		army = params[:dinosaurs].uniq.to_a.map do |dino_id|
			dino = Dinosaur[dino_id]

			if dino && dino.status > 0 && dino.player_id.to_i == @player.id
				dino.update_status!
				render_error(Error::NORMAL, I18n.t('strategy_error.dino_hp_is_zero')) and return if dino.current_hp < dino.total_hp * 0.1
				render_error(Error::NORMAL, I18n.t('strategy_error.dino_is_hungry')) and return if dino.feed_point <= 5
				render_error(Error::NORMAL, I18n.t('strategy_error.dino_is_attacking')) and return if dino.action_status >= 3
				dino
			else
				nil
			end
		end.compact

		if army.blank?
			render_error(Error::NORMAL, I18n.t('strategy_error.send_at_least_one')) and return
		end

		target_monster_type = nil
		target_type = case target.class.name
			when "Village"
				BattleModel::TARGET_TYPE[:village]
			when "Creeps"
				target_monster_type = target.defense_troops.first.type
				BattleModel::TARGET_TYPE[:creeps]
			when "GoldMine"
				BattleModel::TARGET_TYPE[:gold_mine]
		end

		# 计算行军时间
		my_vil = @player.village

		marching_time = Math.sqrt((my_vil.x - target.x)**2 + (my_vil.y - target.y)**2)
		marching_time = 1 if marching_time < 1
		marching_time = 300 if marching_time > 300

		marching_time = 2 if Rails.env.development?

		scroll = Item[params[:scroll_id]]
		scroll_type = scroll ? scroll.item_type : 0

		# 创建Troops
		trps = Troops.new		:player_id => @player.id, 
												:dinosaurs => params[:dinosaurs].to_json,
												:target_type => target_type,
												:target_id => target.id,
												:start_time => Time.now.to_i,
												:arrive_time => Time.now.to_i + marching_time,
												:monster_type => target_monster_type,
												:target_x => target.x,
												:target_y => target.y,
												:scroll_id => params[:scroll_id],
												:scroll_type => scroll_type

		if trps.save
			target.set(:under_attack, 1)

			if target.is_a?(Village) || (target.is_a?(GoldMine) && !target.player_id.blank?)
				vil = Village.new(:id => @player.village_id).gets(:protection_until)
				now_time = ::Time.now.to_i
				vil.set(:protection_until, Time.now.to_i) if vil.protection_until > Time.now.to_i
			end

			army.each do |dino|
				dino_sta = dino.strategy
				if dino_sta
					dino_sta.remove_dinosaur!(dino.id)
				end
				dino.sets(:action_status => Dinosaur::ACTION_STATUS[:attacking], :strategy_id => 0)

				dino.consume_energy(:energy => 50)
			end

			scroll.use! if scroll
		end

		# 主线：使用卷轴
		if Item.exists?(params[:scroll])
			@player.serial_tasks_data[:use_scroll] ||= 0
			@player.serial_tasks_data[:use_scroll] = 1
			@player.set :serial_tasks_data, @player.serial_tasks_data
		end
		
		render_success(:player => @player.to_hash.merge(:troops => [trps.to_hash], :village => @player.village.to_hash(:strategy)))
	end

	def refresh_battle
		@player.troops.each do |trps|
			trps.refresh!
		end
	end

	def get_battle_report
		@player.troops.map(&:refresh!)

		report = @player.find_battle_report_by(:troops_id => params[:troops_id])

		if report
			render_success(report.get_detail[:content])
		else
			render_error(Error::NORMAL, I18n.t('strategy_error.report_has_been_removed'))
		end
	end

	def match_players
		if @player.spend!(@player.match_cost)
			count = 0
			players = []
			Player.none_npc.ids.shuffle!.map do |player_id|
				break if count >= 5
				if player_id.to_i == @player.id
					next
				end

				# player = Player.new(:id => player_id).gets(:nickname, :level, :avatar_id, :honour_strategy, :honour_score)
				player = Player[player_id]

				if not player.has_set_honour_strategy?
					next
				end

				if (@player.honour_score - player.honour_score).abs >= 199
					next
				end

				count += 1
				players << {
					:id => player.id,
					:nickname => player.nickname,
					:level => player.level,
					# TODO: 因客户端战斗力和排行写反
					# :power_point => player.honour_score,
					# :rank => player.my_battle_rank,
					:power_point => player.my_battle_rank,
					:rank => player.honour_score,
					:avatar_id => player.avatar_id
				}
			end
			players.compact!

			render_success 	:gold_coin => @player.gold_coin, 
											:players => players, 
											:todays_count => @player.todays_count, 
											:total_match_count => @player.total_honour_count,
											:buy_count_cost => Shopping::MATCH_COUNT_COST
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gold'))
		end
	end

	def match_attack
		@enemy = Player[params[:enemy_id]]

		if @enemy.nil?
			render_error(Error::NORMAL, "INVALID_ENEMY_ID") and return
		end

		if @player.todays_count <= 0
			render_error(Error::NORMAL, I18n.t('strategy_error.honour_count_full', :count => @player.total_honour_count)) and return
		end

		if (@player.honour_score - @enemy.honour_score).abs >= 199
			render_error(Error::NORMAL, I18n.t('strategy_error.honour_score_not_match')) and return
		end

		player_dinos = @player.honour_strategy.map do |d_id|
			Dinosaur[d_id]
		end.compact

		if player_dinos.blank?
			render_error(Error::NORMAL, I18n.t('strategy_error.you_have_not_set_strategy')) and return
		end

		if @enemy.honour_strategy.blank?
			render_error(Error::NORMAL, I18n.t('strategy_error.enemy_not_set_strategy')) and return
		end

		enemy_dinos = @enemy.honour_strategy.map do |d_id|
			dino = Dinosaur[d_id]
			if dino
				dino.set :current_hp, dino.total_hp
			end
			dino
		end.compact

		attacker = Battler.new :owner => @player, :army => player_dinos, :camp => false

		defender = Battler.new :owner => @enemy, :army => enemy_dinos, :camp => true

		# result = BattleModel.match_attack attacker, defender
		battle = Battle.new :attacker => attacker, :defender => defender, :type => Battle::HONOUR
		battle.start!

		@player.desr_honour_battle_count


		# 主线：使用卷轴
		# if Item.exists?(params[:scroll])
		# 	@player.serial_tasks_data[:use_scroll] ||= 0
		# 	@player.serial_tasks_data[:use_scroll] = 1
		# 	@player.set :serial_tasks_data, @player.serial_tasks_data
		# end

		winner, loser = if battle.result.winner == attacker
			[@player, @enemy]
		else
			[@enemy, @player]
		end

		win_score  = Player.calc_score(winner.honour_score, loser.honour_score)

		if winner == @player && !winner.finish_daily_quest
			winner.daily_quest_cache[:win_match_game] += 1
			winner.daily_quest_cache[:win_honour_val] += win_score
			winner.serial_tasks_data[:win_match_game] ||= 0
			winner.serial_tasks_data[:win_match_game] += 1

			# winner.set :daily_quest_cache, winner.daily_quest_cache.to_json
			winner.save

			GameMail.create_match_lose 	:attacker_id 		=> @player.id,
																	:attacker_name 	=> @player.nickname,
																	:defender_id 		=> @enemy.id,
																	:defender_name 	=> @enemy.nickname,
																	:score 					=> win_score,
																	:locale 				=> @enemy.locale
		else
			GameMail.create_match_win 	:attacker_id 		=> @player.id,
																	:attacker_name 	=> @player.nickname,
																	:defender_id 		=> @enemy.id,
																	:defender_name 	=> @enemy.nickname,
																	:score 					=> win_score,
																	:locale 				=> @enemy.locale
		end

		winner.add_honour(win_score)
		loser.dec_honour(win_score)

		result = battle.result.to_hash

		render_success result.merge(
			:score => @player.honour_score, 
			:my_rank => @player.my_battle_rank, 
			:todays_count => @player.todays_count, 
			:total_match_count => @player.total_honour_count, 
			:buy_count_cost => Shopping::MATCH_COUNT_COST
			)
	end

	def set_match_strategy
		dino_ids = params[:dinosaurs]
		@player.honour_strategy = dino_ids
		if @player.save
			render_success
		else
			render_error(Error::NORMAL, "Known Error")
		end
	end

	def league_goldmine_attack
		# TODO: 时间限制

		@league = @player.league
		if @league.nil?
			render_error(Error::NORMAL, I18n.t('strategy_error.not_in_a_league')) and return
		end

		@gold_mine = GoldMine[params[:gold_mien_id]]
		if @gold_mine.type != GoldMine::TYPE[:league]
			render_error(Error::NORMAL, I18n.t('strategy_error.wrong_type_of_goldmine')) and return
		end

		dino_ids = params[:dinosaurs]

		if dino_ids.blank?
			render_error(Error::NORMAL, I18n.t('strategy_error.send_at_least_one')) and return
		end

		army = dino_id.map do |d_id|
			dino = Dinosaur[d_id]

			if dino && dino.status > 0
				dino.update_status!
				if dino.current_hp <= 0
					render_error(Error::NORMAL, I18n.t('strategy_error.dino_hp_is_zero')) and return
				end

				if dino.is_attacking
					render_error(Error::NORMAL, I18n.t('strategy_error.dino_is_attacking')) and return
				end
				dino
			else
				nil
			end
		end.compact

		if army.blank?
			render_error(Error::NORMAL, I18n.t('strategy_error.send_at_least_one')) and return
		end

		if Troops.create 	:player_id 		=> @player.id, 
											:dinosaurs 		=> dino_ids.to_json,
											:target_type 	=> BattleModel::TARGET_TYPE[:gold_mine],
											:target_id 		=> @gold_mine.id,
											:start_time 	=> Time.now.to_i,
											:arrive_time 	=> Time.now.to_i + 2.seconds,
											:target_x 		=> @gold_mine.x,
											:target_y 		=> @gold_mine.y,
											:scroll_id 		=> params[:scroll_id]

			scroll = Item[params[:scroll_id]]
			scroll.update :player_id => nil if scroll
			@gold_mine.set(:under_attack, 1)

			params[:dinosaurs].each do |dino_id|
				if Dinosaur.exists?(dino_id)
					Ohm.redis.hset("Dinosaur:#{dino_id}", :is_attacking, 1)
				end
			end

			# 主线：使用卷轴
			if Item.exists?(params[:scroll])
				@player.serial_tasks_data[:use_scroll] ||= 0
				@player.serial_tasks_data[:use_scroll] = 1
				@player.set :serial_tasks_data, @player.serial_tasks_data
			end

			render_success(:player => @player.to_hash(:troops))
		end

	end

	def give_up_goldmine
		gold_mine = GoldMine[params[:goldmine_id]]

		if gold_mine && @player.gold_mines.include?(gold_mine)
			gold_mine.update :player_id => nil
		end

		render_success(:gold_mines => @player.gold_mines.map(&:to_hash))
	end
end
