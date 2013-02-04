class WorldMapController < ApplicationController

	before_filter :validate_player, :only => [:attack]

	def country_map
		x, y = params[:x], params[:y]

		x_min = x - 10 <= 0 ? 0 : x - 10
		y_min = y - 10 <= 0 ? 0 : y - 10
		x_max = x + 10 >= Country::MAP_MAX_X - 1 ? Country::MAP_MAX_X - 1 : x + 10
		y_max = y + 10 >= Country::MAP_MAX_Y - 1 ? Country::MAP_MAX_Y - 1 : y + 10

		towns_info = []
		gold_mines_info = []
		hl_gold_mine_info = []
		creeps_info = []

		ids = (x_min..x_max).map do |i|
			(y_min..y_max).map do |j|
				i + j * Country::COORD_TRANS_FACTOR
			end
		end.flatten

		country = Country[params[:country_id]]
		if country.nil?
			render(:json => []) and return
		end

		country_map = country.town_nodes_info
		gold_mine_map = country.gold_mine_info

		left_ids = ids.dup

		ids.each do |i|
			if country_map[i].to_i > 0
				vil = Village.with(:index, i)
				vx = i % Country::COORD_TRANS_FACTOR
				vy = i / Country::COORD_TRANS_FACTOR

				player = Player.new
				league = League.new
				vil_name = ""
				v_type = 0

				if vil.nil?
					vil = Village.new :id => 0, :name => "", :type => [1, 2].sample
					vil_name = I18n.t("player.empty_village_name")
					league.name = ""
				else
					player = Player.new :id => vil.player_id
					v_type = 1
					player.gets(:nickname, :league_id, :avatar_id, :battle_power, :locale, :level)
					vil_name = I18n.t("player.whos_village", :player_name => player.nickname)
					league = League.new :id => player.league_id

					league.get :name
				end

				towns_info << {
					:x => vx,
					:y => vy,
					:info => {
						:type => v_type,
						:id => vil.id,
						:player_id => vil.player_id.to_i,
						:name => vil_name,
						:village_level => player.village_level,
						:player_level => player.level,
						:league_name => league.name,
						:avatar_id => player.avatar_id,
						:battle_power => player.battle_power,
						:village_type => vil.type
					}
				}
				left_ids -= CountryDataHelper::InstanceMethods.get_nodes_matrix(vx - 2, vy - 2, 5, 5)
				next
			end

			if gold_mine_map[i].to_i > 0
				gx = i % Country::COORD_TRANS_FACTOR
				gy = i / Country::COORD_TRANS_FACTOR

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
				left_ids -= CountryDataHelper::InstanceMethods.get_nodes_matrix(gx - 2, gx - 2, 5, 5)
				next
			end

			if country.hl_gold_mine_info[i].to_i > 0
				gx = i % Country::COORD_TRANS_FACTOR
				gy = i / Country::COORD_TRANS_FACTOR

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
				left_ids -= CountryDataHelper::InstanceMethods.get_nodes_matrix(gx - 2, gx - 2, 5, 5)
				next
			end
		end # end of ids each

		if Player.exists?(params[:player_id])
			left_ids.select!{ |idx| country.empty_map_info[idx] >= 0 }

			player = Player.new :id => params[:player_id]
			tmp_creeps_idx = player.temp_creeps_idx & left_ids
			
			if tmp_creeps_idx.size <= 0
				new_creeps_index = left_ids.sample
				cx = new_creeps_index % Country::COORD_TRANS_FACTOR
				cy = new_creeps_index / Country::COORD_TRANS_FACTOR

				m_level = rand(1..4)
				m_count = case m_level
				when 1..5
					1
				when 6..10
					2
				when 11..20
					3
				when 20..30
					4
				else
					5
				end
				m_type = rand(1..4)

				creeps_atts = {:x => cx, :y => cy, :level => m_level, :type => m_type, :monster_number => m_count}
				player.save_creeps(creeps_atts)
				creeps_info << {
					:x => cx,
					:y => cy,
					:info => {
						:type => 2,
						:id => new_creeps_index,
						:name => "Creeps",
						:level => m_level,
						:monster_type => m_type,
						:owner_name => "Creeps",
						:monster_number => m_count,
						:under_attack => false,
						:is_quest_monster => true,
						:player_id => player.id
					}
				}
			else
				tmp_creeps_idx.each do |tmp_index|
					info = player.temp_creeps(tmp_index)
					if info
						creeps_info << {
							:x => info['x'],
							:y => info['y'],
							:info => {
								:type => 2,
								:id => tmp_index,
								:name => "Creeps",
								:level => info['level'],
								:monster_type => info['type'],
								:owner_name => "Creeps",
								:monster_number => info['monster_number'],
								:under_attack => false,
								:is_quest_monster => true,
								:player_id => player.id
							}
						}
					end
				end
			end

		end

		render :json => {:country_map => towns_info + gold_mines_info + hl_gold_mine_info + creeps_info}
	end

end
