class StrategyController < ApplicationController

	before_filter :validate_village, :only => [:set_defense]
	before_filter :validate_player, :only => [:attack]

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
			Dinosaur[dino_id]
		end.compact

		army = army.blank? ? @player.dinosaurs.to_a : army

		attacker = {
			:owner_info => {
				:type => 'Player',
				:id => params[:player_id]
			},
			:buff_info => {},
			:army => army
		}

		defender = {
			:owner_info => {
				:type => target.class.name,
				:id => target.id
			},
			:buff_info => {},
			:army => target.defense_troops
		}

		result = BattleModel.attack_calc(attacker, defender)

		if result[:winner] == "attacker"
			target.update :player_id => @player.id
		end

		render :json => {
			:message => Error.success_message,
			:result => result
		}

	end
end
