class StrategyController < ApplicationController

	before_filter :validate_village, :only => [:set_defense]
	before_filter :validate_player, :only => [:attack, :get_battle_report, :refresh_battle, :match_players, :match_attack, :set_match_strategy]

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
				Creeps.create(creeps_info)
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

		if target.is_a?(GoldMine) && target.player_id.to_i == @player.id
			render_error(Error::NORMAL, "The gold mine is yours") and return
		end

		army = params[:dinosaurs].to_a.map do |dino_id|
			dino = Dinosaur[dino_id]
			if dino && dino.status > 0
				dino
			else
				nil
			end
		end.compact

		army = army.blank? ? @player.dinosaurs.to_a.select{|d| d.status > 0}[0, 5] : army

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
		render :json => {
			:message => Error.success_message,
			:player => @player.to_hash(:troops)
		}
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
		players = Player.find(:player_type => 0).union(:player_type => 1).ids.sample(5).map do |player_id|
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
		render_success(:players => players)
	end

	def match_attack
		@enemy = Player[enemy_id]

		if @enemy.nil?
			render_error(Error::NORMAL, "Invalid enemy id") and return
		end

		player_dinos = @player.honour_strategy.map { |d_id| Dinosaur[d_id] }
		enemy_dinos = @enemy.honour_strategy.map { |d_id| Dinosaur[d_id] }

		result = BattleModel.attack_calc player_dinos, enemy_dinos
		render_success(result)
	end

	def set_match_strategy

	end
end
