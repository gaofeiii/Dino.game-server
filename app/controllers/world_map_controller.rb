class WorldMapController < ApplicationController

	before_filter :validate_player, :only => [:attack]

	def country_map
		x, y = params[:x], params[:y]
		last_x, last_y = params[:last_x], params[:last_y]

		x_min = x - 8 <= 0 ? 0 : x - 8
		y_min = y - 8 <= 0 ? 0 : y - 8
		x_max = x + 8 >= Country::MAP_MAX_X - 1 ? Country::MAP_MAX_X - 1 : x + 8
		y_max = y + 8 >= Country::MAP_MAX_Y - 1 ? Country::MAP_MAX_Y - 1 : y + 8

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

		ids.each do |i|
			if country_map[i].to_i > 0
				# puts "--- index: #{i}"
				vil = Village.with(:index, i)
				vx = i / Country::COORD_TRANS_FACTOR
				vy = i % Country::COORD_TRANS_FACTOR
				puts "--- village coords: (#{vx}, #{vy})"
				tp, vid, nm, lv, l_name, avatar_id, battle_power = if vil
					l_id, ava_id, bp = Ohm.redis.hmget(Player.key[vil.player_id], :league_id, :avatar_id, :battle_power)
					[1, vil.id.to_i, vil.name, vil.level, League.get(l_id, :name).to_s, ava_id, bp]
				else
					[0, 0, "Blank Village", 0, "", 0, 0]
				end


				towns_info << {
					:x => i / Country::COORD_TRANS_FACTOR, 
					:y => i % Country::COORD_TRANS_FACTOR, 
					:info => {
						:type => tp, 
						:id => vid, 
						:name => nm, 
						:level => lv,
						:league_name => l_name,
						:avatar_id => avatar_id.to_i,
						:battle_power => battle_power.to_i
					}
				}
			end

			if gold_mine_map[i].to_i > 0
				x = i / Country::COORD_TRANS_FACTOR
				y = i % Country::COORD_TRANS_FACTOR

				g_mine = GoldMine.find(:x => x, :y => y).first
				next if g_mine.nil?

				gold_mines_info << {
					:x => i / Country::COORD_TRANS_FACTOR,
					:y => i % Country::COORD_TRANS_FACTOR,
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
			end

			if country.hl_gold_mine_info[i].to_i > 0
				x = i / Country::COORD_TRANS_FACTOR
				y = i % Country::COORD_TRANS_FACTOR

				g_mine = GoldMine.find(:x => x, :y => y).first
				next if g_mine.nil?

				hl_gold_mine_info << {
					:x => x,
					:y => y,
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
			end

			if country.creeps_info[i].to_i > 0
				x = i / Country::COORD_TRANS_FACTOR
				y = i % Country::COORD_TRANS_FACTOR
				creeps = Creeps.find(:x => x, :y => y).first
				next if creeps.nil?
				c_info = {
					:x => x,
					:y => y,
					:info => {
						:type => 2,
						:id => creeps.id,
						:name => 'Creeps',
						:level => creeps.level,
						:monster_type => creeps.type,
						:owner_name => 'Creeps',
						:monster_number => creeps.monster_number,
						:under_attack => creeps.under_attack
					}
				}
				creeps_info << c_info
			end

			# 新手野怪
			if country.quest_monster.include?(i)
				begin_x = i / Country::COORD_TRANS_FACTOR
				begin_y = i % Country::COORD_TRANS_FACTOR
				creeps = Creeps.find(:x => begin_x, :y => begin_y).first
				if !creeps.nil?
					creeps_info << {
						:x => begin_x,
						:y => begin_y,
						:info => {
							:type => 2,
							:id => creeps.id,
							:name => 'Creeps',
							:level => 1,
							:monster_type => creeps.type,
							:owner_name => 'Creeps',
							:monster_number => creeps.monster_number,
							:under_attack => creeps.under_attack,
							:is_quest_monster => creeps.is_quest_monster,
							:player_id => creeps.player_id.to_i
						}
					}
				end
			end
			
			


		end

		render :json => {:country_map => towns_info + gold_mines_info + hl_gold_mine_info + creeps_info}
	end

	def attack
		render :json => {:message => 'attack!'}
	end
end
