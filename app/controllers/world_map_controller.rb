class WorldMapController < ApplicationController

	before_filter :validate_player, :only => [:attack]

	def country_map
		x, y = params[:x], params[:y]
		last_x, last_y = params[:last_x], params[:last_y]

		x_min = x - 8 <= 0 ? 0 : x - 8
		y_min = y - 6 <= 0 ? 0 : y - 6
		x_max = x + 8 >= Country::MAP_MAX_X - 1 ? Country::MAP_MAX_X - 1 : x + 8
		y_max = y + 6 >= Country::MAP_MAX_Y - 1 ? Country::MAP_MAX_Y - 1 : y + 6

		# puts "=== range: -from(#{x_min},#{y_min}), -to(#{x_max}, #{y_max})"


		towns_info = []
		gold_mines_info = []
		hl_gold_mine_info = []
		creeps_info = []

		ids = (x_min..x_max).map do |i|
			(y_min..y_max).map do |j|
				i * Country::COORD_TRANS_FACTOR + j
			end
		end.flatten
		country = Country.first
		country_map = country.town_nodes_info
		gold_mine_map = country.gold_mine_info

		left_ids = ids.dup

		ids.each do |i|
			if country_map[i].to_i > 0
				# puts "--- index: #{i}"
				vil = Village.with(:index, i)
				vx = i / Country::COORD_TRANS_FACTOR
				vy = i % Country::COORD_TRANS_FACTOR

				player = Player.new
				league = League.new
				vil_name = ""

				if vil.nil?
					vil = Village.new :id => 0, :name => ""
					vil_name = I18n.t("player.empty_village_name")
					league.name = ""
				else
					player = Player.new :id => vil.player_id
					player.gets(:nickname, :league_id, :avatar_id, :battle_power, :locale, :level)
					vil_name = I18n.t("player.whos_village", :player_name => player.nickname)
					league = League.new :id => player.league_id

					league.get :name
				end

				towns_info << {
					:x => vx,
					:y => vy,
					:info => {
						:type => 1, 
						:id => vil.id, 
						:name => vil_name,
						:level => player.level,
						:league_name => league.name,
						:avatar_id => player.avatar_id,
						:battle_power => player.battle_power
					}
				}
				left_ids = CountryDataHelper::InstanceMethods.get_nodes_matrix(vx - 2, vy - 2, 5, 5)
				next
			end

			if gold_mine_map[i].to_i > 0
				gx = i / Country::COORD_TRANS_FACTOR
				gy = i % Country::COORD_TRANS_FACTOR

				g_mine = GoldMine.find(:x => gx, :y => gy).first
				next if g_mine.nil?

				gold_mines_info << {
					:x => gx,
					:y => gy,
					:info => {
						:type => 3,
						:id => g_mine.id,
						:name => "Gold Mine",
						:level => g_mine.level,
						:owner_name => g_mine.owner_name,
						:output => g_mine.output,
						:left_time => 0
					}
				}
				left_ids = CountryDataHelper::InstanceMethods.get_nodes_matrix(gx - 2, gx - 2, 5, 5)
				next
			end

			if country.hl_gold_mine_info[i].to_i > 0
				gx = i / Country::COORD_TRANS_FACTOR
				gy = i % Country::COORD_TRANS_FACTOR

				g_mine = GoldMine.find(:x => gx, :y => gy).first
				next if g_mine.nil?

				hl_gold_mine_info << {
					:x => gx,
					:y => gy,
					:info => {
						:type => 3,
						:id => g_mine.id,
						:name => "Gold Mine(Difficult)",
						:level => g_mine.level,
						:owner_name => g_mine.owner_name,
						:output => g_mine.output,
						:left_time => 0
					}
				}
				left_ids = CountryDataHelper::InstanceMethods.get_nodes_matrix(gx - 2, gx - 2, 5, 5)
				next
			end

			# if country.creeps_info[i].to_i > 0
			# 	x = i / Country::COORD_TRANS_FACTOR
			# 	y = i % Country::COORD_TRANS_FACTOR
			# 	creeps = Creeps.find(:x => x, :y => y).first
			# 	next if creeps.nil?
			# 	c_info = {
			# 		:x => x,
			# 		:y => y,
			# 		:info => {
			# 			:type => 2,
			# 			:id => creeps.id,
			# 			:name => 'Creeps',
			# 			:level => creeps.level,
			# 			:monster_type => creeps.type,
			# 			:owner_name => 'Creeps',
			# 			:monster_number => creeps.monster_number,
			# 			:under_attack => creeps.under_attack
			# 		}
			# 	}
			# 	creeps_info << c_info
			# end

			# 新手野怪
			# if country.quest_monster.include?(i)
			# 	begin_x = i / Country::COORD_TRANS_FACTOR
			# 	begin_y = i % Country::COORD_TRANS_FACTOR
			# 	creeps = Creeps.find(:x => begin_x, :y => begin_y).first
			# 	if !creeps.nil?
			# 		creeps_info << {
			# 			:x => begin_x,
			# 			:y => begin_y,
			# 			:info => {
			# 				:type => 2,
			# 				:id => creeps.id,
			# 				:name => 'Creeps',
			# 				:level => 1,
			# 				:monster_type => creeps.type,
			# 				:owner_name => 'Creeps',
			# 				:monster_number => creeps.monster_number,
			# 				:under_attack => creeps.under_attack,
			# 				:is_quest_monster => creeps.is_quest_monster,
			# 				:player_id => creeps.player_id.to_i
			# 			}
			# 		}
			# 	end
			# end
			
		


		end # end of ids each

		[left_ids.sample].each do |creeps_coords|
			cx = creeps_coords / Country::COORD_TRANS_FACTOR
			cy = creeps_coords % Country::COORD_TRANS_FACTOR

			creeps = Creeps.new :x => cx, :y => cy, :level => rand(1..4), :type => rand(1..4)
			creeps_info << {
				:x => cx,
				:y => cy,
				:info => {
					:type => 2,
					:id => 1,
					:name => "Creeps",
					:level => creeps.level,
					:monster_type => creeps.type,
					:owner_name => "Creeps",
					:monster_number => creeps.monster_number,
					:under_attack => creeps.under_attack,
					:is_quest_monster => true,
					:player_id => 1
				}
			}
		end

		render :json => {:country_map => towns_info + gold_mines_info + hl_gold_mine_info + creeps_info}
	end

end
