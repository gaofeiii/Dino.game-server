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
				:error => Error.format("wrong type of host")
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
end
