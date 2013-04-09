class GoldMineController < ApplicationController

	before_filter :validate_player

	def upgrade
		
		@gold_mine = GoldMine[:gold_mine_id]

		render_error(Error::NORMAL, "GoldMine dosen't belong to you!!!") and return if @gold_mine.player != @player

		if @gold_mine.is_normal?
			if @player.spend!(g.next_level_cost)
				@gold_mine.update :level => @gold_mine.level + 1
				render_success(:gold_mine => @gold_mine.to_hash)
			else
				render_error(Error::NORMAL, "not enough resource")
			end
		else
			render_error(Error::NORMAL, "Will open later")
		end
	end

end
