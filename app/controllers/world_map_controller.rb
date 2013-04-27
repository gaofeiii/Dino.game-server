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

				vil_type = if vx.in?(Country::GOLD_MINE_X_RANGE) && vy.in?(Country::GOLD_MINE_Y_RANGE)
					Village::TYPE[:dangerous]
				else
					Village::TYPE[:normal]
				end

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
					player.gets(:nickname, :league_id, :avatar_id, :battle_power, :locale, :level, :player_type)
					vil_name = I18n.t("player.whos_village", :player_name => player.nickname)
					league = League.new :id => player.league_id

					league.get :name
				end

				monster_type = 0
				if vil.is_bill?
					v_type = 2
					monster_type = 7
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
						:village_type => vil_type,
						:under_protection => vil.under_protection,
						:is_vip => player.is_vip?,
						:monster_type => monster_type
					}
				}
				left_ids -= CountryDataHelper::InstanceMethods.get_nodes_matrix(vx - 2, vy - 2, 5, 5)
				next # ids
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
						:owner_id => g_mine.player_id.to_i,
						:output => g_mine.output,
						:goldmine_type => g_mine.goldmine_type,
						:goldmine_cat => g_mine.goldmine_cat,
						:left_time => 0,
						:can_attack => true
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
						:goldmine_type => g_mine.goldmine_type,
						:goldmine_cat => g_mine.goldmine_cat,
						:left_time => LeagueWar.time_left,
						:league_id => g_mine.league_id.to_i,
						:can_attack => LeagueWar.in_period_of_fight?
					}
				}
				left_ids -= CountryDataHelper::InstanceMethods.get_nodes_matrix(gx - 2, gx - 2, 5, 5)
				next
			end
		end # end of ids each

		my_x, my_y = 0, 0
		if Player.exists?(params[:player_id])
			left_ids.select!{ |idx| country.empty_map_info[idx] >= 0 }

			player = Player.new(:id => params[:player_id])#.gets(:adapt_level)
			player.update_adapt_level

			tmp_creeps_idx = player.temp_creeps_idx & left_ids

			vil = Village.new(:id => player.gets(:village_id).village_id).gets(:x, :y)
			my_x, my_y = vil.x, vil.y

			if tmp_creeps_idx.size <= 0
				# 如果有新手指引攻打野怪的任务，创建任务野怪
				guide = player.beginner_guides.find(:index => 8).first
				if !player.beginning_guide_finished && (!guide || guide.finished == false)
					guide_creeps_atts = {:x => vil.x, :y => vil.y - 3, :level => 1, :type => rand(1..4), :monster_number => 1, :guide_creeps => true}
					player.save_creeps(guide_creeps_atts)
				end

				new_creeps_index = left_ids.sample
				cx = new_creeps_index % Country::COORD_TRANS_FACTOR
				cy = new_creeps_index / Country::COORD_TRANS_FACTOR

				unless cx.in?(Country::GOLD_MINE_X_RANGE) && cy.in?(Country::GOLD_MINE_Y_RANGE)
					min = player.adapt_level - 5
					min = 1 if min <= 0
					m_level = rand(min..player.adapt_level)
					m_count = case m_level
					when 1
						1
					when 2..3
						2
					when 4..5
						3
					when 6..8
						4
					when 9..10
						5
					else
						5
					end
					m_type = rand(1..5)

					creeps_atts = {:x => cx, :y => cy, :level => m_level, :type => m_type, :monster_number => m_count, :guide_creeps => false}

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
							:is_quest_monster => false,
							:player_id => player.id
						}
					}
				end
			end

			tmp_creeps_idx = player.temp_creeps_idx & left_ids # 重新读取缓存的野怪信息
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
							:is_quest_monster => info['guide_creeps'],
							:player_id => player.id
						}
					}
				end
			end

		end

		render :json => {:my_x => my_x, :my_y => my_y, :country_map => towns_info + gold_mines_info + hl_gold_mine_info + creeps_info}
	end

end
