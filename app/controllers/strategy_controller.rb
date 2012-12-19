class StrategyController < ApplicationController

	before_filter :validate_village, :only => [:set_defense]
	before_filter :validate_player, :only => [:attack, :get_battle_report, :refresh_battle]

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
			sta.set :dinosaurs, params[:dinosaurs].to_json
		end
		
		if sta.nil?
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("wrong type of host")
			}
			return
		end

		render :json => {
			:message => Error.success_message,
			:village => {
				:strategy => sta.to_hash
			}
		}
	end

	def attack
		target = if params[:village_id]
			Village[params[:village_id]]
		elsif params[:gold_mine_id]
			GoldMine[params[:gold_mine_id]]
		elsif params[:creeps_id]
			Creeps[params[:creeps_id]]
		else
			nil
		end

		if target.nil?
			render_error(Error.types[:normal], "Invalid target") and return
		end

		if target.is_a?(Village) && target.player_id.to_i = @player.id
			render_error(Error.types[:normal], "Cannot attack your own village") and return
		end

		if target.is_a?(GoldMine) && target.player_id.to_i == @player.id
			render_error(Error.types[:normal], "The gold mine is yours") and return
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

		# attacker = {
		# 	:owner_info => {
		# 		:type => 'Player',
		# 		:id => params[:player_id]
		# 	},
		# 	:buff_info => {},
		# 	:army => army
		# }

		# defender = {
		# 	:owner_info => {
		# 		:type => target.class.name,
		# 		:id => target.id
		# 	},
		# 	:buff_info => {},
		# 	:army => target.defense_troops
		# }

		# result = BattleModel.attack_calc(attacker, defender)
		# @player.save_battle_report(Time.now.to_i, result.to_json)

		# if result[:winner] == "attacker"
		# 	if target.is_a?(GoldMine)
		# 		target.update :player_id => @player.id
		# 	elsif target.is_a?(Creeps)
		# 		target.delete
		# 	end
		# end

		target_type = case target.class.name
			when "Village"
				1
			when "Creeps"
				2
			when "GoldMine"
				3
			else
				0
		end

		Troops.create :player_id => @player.id, 
									:dinosaurs => params[:dinosaurs].to_json,
									:target_type => target_type,
									:target_id => target.id,
									:start_time => Time.now.to_i,
									:arrive_time => Time.now.to_i + 30.seconds
		if !@player.beginning_guide_finished && !@player.guide_cache['attack_monster']
			@player.set :guide_cache, @player.guide_cache.merge('attack_monster' => true)
		end
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
		render_success(:report => @player.get_battle_report)
	end
end
