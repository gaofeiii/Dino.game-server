class RankController < ApplicationController

	def player_rank
		render_success(:players => Player.battle_rank)
	end

	def league_rank
		render_success(:leagues => League.battle_rank)
	end

end
