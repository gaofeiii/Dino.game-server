class StrategyController < ApplicationController

	before_filter :validate_village, :only => [:set_defense]
	before_filter :validate_player, :only => [:attack, :get_battle_report, :refresh_battle, :match_players, 
		:match_attack, :set_match_strategy, :league_goldmine_attack]

	def set_defense

		sta = @village.strategy

		if sta.nil?
			sta = if params[:village_id]
				Strategy.create :village_id => params[:village_id],
												:player_id => @village.player_id,
												:dinosaurs => params[:dinosaurs].to_json
			elsif params[:gold_mine_id]
				Strategy.create :gold_mine_id => params[:gold_mine_id],
												:player_id => @village.player_id,
												:dinosaurs => params[:dinosaurs].to_json
			else
				nil
			end
			@village.set(:strategy_id, sta.id) if sta && @village.strategy_id.blank?
		else
			JSON.parse(sta.dinosaurs).each do |dino_id|
				if Dinosaur.exists?(dino_id)
					Ohm.redis.hset("Dinosaur:#{dino_id}", :is_deployed, 0)
				end
			end
			sta.set :dinosaurs, params[:dinosaurs].to_json
			params[:dinosaurs].each do |dino_id|
				if Dinosaur.exists?(dino_id)
					Ohm.redis.hset("Dinosaur:#{dino_id}", :is_deployed, 1)
				end
			end
		end
		
		if sta.nil?
			render_error(Error::NORMAL, "wrong type of host")
		else
			@player = Player.new(:id => @village.player_id)
			@player.gets :guide_cache, :beginning_guide_finished
			if !@player.beginning_guide_finished && !@player.guide_cache['set_defense']
				cache = @player.guide_cache.merge(:set_defense => true)
				@player.set :guide_cache, cache
			end
			data = {:player => {:village => {:strategy => sta.to_hash}}}
			render_success(data)
		end
	end

	def attack
		target = if params[:village_id]
			Village[params[:village_id]]
		elsif params[:gold_mine_id]
			GoldMine[params[:gold_mine_id]]
		elsif params[:creeps_id]
			# Creeps[params[:creeps_id]]
			creeps_info = @player.temp_creeps(params[:creeps_id])
			if creeps_info.nil?
				nil
			else
				Creeps.create(creeps_info.except('guide_creeps'))
			end
		else
			nil
		end

		if target.blank?
			render_error(Error::NORMAL, "Invalid target") and return
		end

		if target.is_a?(Village) && target.player_id.to_i == @player.id
			render_error(Error::NORMAL, "Cannot attack your own village") and return
		end

		if target.is_a?(GoldMine)
			if target.type == GoldMine::TYPE[:normal] && target.player_id.to_i == @player.id
				render_error(Error::NORMAL, "The gold mine is yours") and return
			elsif target.type == GoldMine::TYPE[:league] && @player.league_id.blank?
				render_error(Error::NORMAL, I18n.t('strategy_error.not_in_a_league')) and return
			end
		end

		if target.is_a?(Creeps)
			if target.under_attack
				render_error(Error::NORMAL, "Target is under attack") and return
			end
		end

		army = params[:dinosaurs].to_a.map do |dino_id|
			dino = Dinosaur[dino_id]

			if dino && dino.status > 0
				dino.update_status!
				if dino.current_hp <= dino.total_hp * 0.05
					render_error(Error::NORMAL, I18n.t('strategy_error.dino_hp_is_zero')) and return
				end
				dino
			else
				nil
			end
		end.compact

		# army = army.blank? ? @player.dinosaurs.to_a.select{|d| d.status > 0}[0, 5] : army
		if army.blank?
			render_error(Error::NORMAL, "Should sent one dinosaur at least") and return
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

		if Troops.create 	:player_id => @player.id, 
											:dinosaurs => params[:dinosaurs].to_json,
											:target_type => target_type,
											:target_id => target.id,
											:start_time => Time.now.to_i,
											:arrive_time => Time.now.to_i + 2.seconds,
											:monster_type => target_monster_type,
											:target_x => target.x,
											:target_y => target.y,
											:scroll_id => params[:scroll_id]
			target.set(:under_attack, 1)
			params[:dinosaurs].each do |dino_id|
				if Dinosaur.exists?(dino_id)
					Ohm.redis.hset("Dinosaur:#{dino_id}", :is_attacking, 1)
				end
			end
		end
		# if !@player.beginning_guide_finished && !@player.guide_cache['attack_monster']
		# 	@player.set :guide_cache, @player.guide_cache.merge('attack_monster' => true)
		# end
		render_success(:player => @player.to_hash(:troops))
	end

	def refresh_battle
		@player.troops.each do |trps|
			trps.refresh!
		end
	end

	def get_battle_report
		@player.troops.map(&:refresh!)
		report = @player.get_battle_report_with_troops_id(params[:troops_id])
		if report
			render_success(report)
		else
			render_error(Error::NORMAL, "Report has been cleaned")
		end
	end

	def match_players
		if @player.spend!(@player.match_cost)
			players = Player.find(:player_type => 0).union(:player_type => 1).ids.sample(5).map do |player_id|
				if player_id.to_i == @player.id
					next
				end

				player = Player.new(:id => player_id).gets(:nickname, :level, :avatar_id)
				{
					:id => player.id,
					:nickname => player.nickname,
					:level => player.level,
					:power_point => rand(1..5000),
					:rank => rand(1..Player.count),
					:avatar_id => player.avatar_id
				}
			end
			render_success(:gold_coin => @player.gold_coin, :players => players)
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gold'))
		end
	end

	def match_attack
		@enemy = Player[params[:enemy_id]]

		if @enemy.nil?
			render_error(Error::NORMAL, "Invalid enemy id") and return
		end

		player_dinos = @player.honour_strategy.map do |d_id|
			dino = Dinosaur[d_id]
			if dino
				dino.set :current_hp, dino.total_hp
			end
			dino
		end.compact

		if @enemy.honour_strategy.blank?
			render_error(Error::NORMAL, "Enemy's army not set") and return
		end

		enemy_dinos = @enemy.honour_strategy.map do |d_id|
			dino = Dinosaur[d_id]
			if dino
				dino.set :current_hp, dino.total_hp
			end
			dino
		end.compact

		attacker = {
			:owner_info => {
				:type => 'Player',
				:id => @player.id,
				:name => @player.nickname,
				:avatar_id => @player.avatar_id
			},
			:buff_info => [],
			:army => player_dinos
		}

		defender = {
			:owner_info => {
				:type => 'Player',
				:id => @enemy.id,
				:name => @enemy.nickname,
				:avatar_id => @enemy.avatar_id
			},
			:buff_info => [],
			:army => enemy_dinos
		}

		result = BattleModel.match_attack attacker, defender
		render_success(result)
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
			render_error(Error::NORMAL, "Should sent one dinosaur at least") and return
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
			render_error(Error::NORMAL, "Should sent one dinosaur at least") and return
		end

		if Troops.create 	:player_id => @player.id, 
											:dinosaurs => dino_ids.to_json,
											:target_type => BattleModel::TARGET_TYPE[:gold_mine],
											:target_id => @gold_mine.id,
											:start_time => Time.now.to_i,
											:arrive_time => Time.now.to_i + 2.seconds,
											:target_x => @gold_mine.x,
											:target_y => @gold_mine.y,
											:scroll_id => params[:scroll_id]

			@gold_mine.set(:under_attack, 1)
			params[:dinosaurs].each do |dino_id|
				if Dinosaur.exists?(dino_id)
					Ohm.redis.hset("Dinosaur:#{dino_id}", :is_attacking, 1)
				end
			end

			render_success(:player => @player.to_hash(:troops))
		end

	end
end
