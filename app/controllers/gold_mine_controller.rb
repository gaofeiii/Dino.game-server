class GoldMineController < ApplicationController

	before_filter :validate_player

	def upgrade
		
		@gold_mine = GoldMine[params[:gold_mine_id]]

		if @gold_mine.is_normal?
			render_error(Error::NORMAL, "GoldMine dosen't belong to you!!!") and return if @gold_mine.player != @player

			if @player.spend!(@gold_mine.next_level_cost)
				@gold_mine.update :level => @gold_mine.level + 1
				@player.serial_tasks_data[:upgrade_goldmine] ||= 0
				@player.serial_tasks_data[:upgrade_goldmine] = @gold_mine.level if @player.serial_tasks_data[:upgrade_goldmine] < @gold_mine.level

				render_success 	:gold_mine => @gold_mine.to_hash(:gold_inc => @player.tech_gold_inc), 
												:current_wood => @player.wood, 
												:current_stone => @player.stone
			else
				render_error(Error::NORMAL, "player: not enough resource")
			end
		else
			@league = @player.league
			if @league.nil? || @gold_mine.league == @league.id
				render_error(Error::NORMAL, "GoldMine dosen't belong to your tribe!!!") and return
			end

			if @league.spend_res(@gold_mine.next_level_cost)
				@gold_mine.update :level => @gold_mine.level + 1
				render_success(:gold_mine => @gold_mine.to_hash, :current_wood => @league.wood, :current_stone => @league.stone)
			else
				render_error(Error::NORMAL, "league: not enough resource")
			end
		end

	end

end
