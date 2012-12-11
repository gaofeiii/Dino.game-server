class StrategyController < ApplicationController

	def set_defense

		sta = if params[:village_id]
			Strategy.create :village_id => params[:village_id],
											:player_id => params[:player_id],
											:dinosaurs => params[:dinosaurs].to_json
		elsif params[:gold_mine_id]
			Strategy.create :gold_mine_id => params[:gold_mine_id],
											:player_id => params[:player_id],
											:dinosaurs => params[:dinosaurs].to_json
		else
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
		player = Player[player_id]
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

		troops = Troops.create  :dinosaurs => params[:dinosaurs].to_json,
														:player_id => player.id

	end
end
