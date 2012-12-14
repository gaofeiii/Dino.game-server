class StrategyController < ApplicationController

	before_filter :validate_village, :only => [:set_defense]

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
		player = Player[params[:player_id]]
		target = if params[:village_id]
			Village[params[:village_id]]
		elsif params[:gold_mine_id]
			GoldMine[params[:gold_mine_id]]
		else
			nil
		end

		if target.nil?
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("Invalid target")
			}
			return
		end

		# army = params[:dinosaurs].to_a.map do |dino_id|
		# 	Dinosaur[dino_id]
		# end.compact
		army = player.dinosaurs.to_a

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
		render :json => {
			:message => Error.success_message,
			:result => result
		}
		

	end
end
