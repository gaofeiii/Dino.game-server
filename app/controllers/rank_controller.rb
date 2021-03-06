class RankController < ApplicationController

	def player_rank
		result = Player.battle_rank
		
		has_record = false
		result.each do |player|
			if player[:id] == params[:player_id].to_i
				has_record = true
				break
			end
		end

		if !has_record
			result = [Player[params[:player_id]].to_rank_hash] + result
		end

		render_success(:players => result)
	end

	def league_rank
		render_success(:leagues => League.battle_rank)
	end

end
