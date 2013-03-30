class CaveController < ApplicationController

	before_filter :validate_player

	def attack_cave
		index = params[:index].to_i
		dino_ids = params[:dinosaurs].to_a.uniq

		@player.update_caves_info

		render_error(Error::NORMAL, I18n.t('cave_error.cave_is_locked')) and return if index > @player.latest_cave.index
		render_error(Error::NORMAL, I18n.t('cave_error.no_dino_sent')) and return if dino_ids.empty?
		
		@cave = @player.find_cave(index)

		@cave.update_cave_status
		if @cave.todays_count >= PlayerCave::TOTAL_COUNT
			render_error(Error::NORMAL, I18n.t('cave_error.reach_cave_max')) and return
		end

		player_dinos = dino_ids.map do |dino_id|
			dino = Dinosaur[dino_id]

			if dino && dino.status > 0
				dino.update_status!
				if dino.current_hp < dino.total_hp * 0.1
					render_error(Error::NORMAL, I18n.t('strategy_error.dino_hp_is_zero')) and return
				end
				dino
			else
				nil
			end
		end.compact

		attacker = {
			:player => @player,
			:owner_info => {
				:type => 'Player',
				:id => @player.id,
				:name => @player.nickname,
				:avatar_id => @player.avatar_id
			},
			:buff_info => [],
			:scroll_effect => {},
			:army => player_dinos
		}

		enemy_dinos = @cave.defense_troops
		defender = {
			:player => nil,
			:owner_info => {
				:type => 'Creeps',
				:id => @cave.id,
				:name => @cave.name(:locale => @player.locale),
				:avatar_id => 0,
				:monster_type => enemy_dinos.sample.type
			},
			:buff_info => [],
			:scroll_effect => {},
			:army => enemy_dinos
		}

		result = BattleModel.cave_attack(attacker, defender)

		rounds_count = result[:all_rounds].size

		stars = PlayerCave.cave_rounds_stars(rounds_count)

		reward = {}
		default_reward = {:wood => @cave.index * 10, :stone => @cave.index * 10}

		if result[:winner] == 'attacker'
			case stars
			when 1
				reward = default_reward
			when 2
				reward = @cave.info[:reward] if Tool.rate(@cave.star_2_chance)
			when 3
				if !@cave.get_perfect_reward
					reward = @cave.info[:reward]
					@cave.get_perfect_reward = true
				else
					reward = @cave.info[:reward] if Tool.rate(@cave.star_3_chance)
				end
			end

			reward = default_reward if reward.blank?

			if !reward[:item_cat].nil?
				result[:reward][:items] ||= []
				result[:reward][:items] << reward
			else
				result[:reward] = reward
			end

			@player.receive_reward!(reward)

			# === Guide ===
			@player.gets :guide_cache, :beginning_guide_finished
			if !@player.beginning_guide_finished && !@player.guide_cache['attack_cave']
				cache = @player.guide_cache.merge(:attack_cave => true)
				@player.set :guide_cache, cache
			end
			# === End of Guide ===

			@cave.todays_count += 1
			@cave.stars = stars if @cave.stars < stars
			@cave.save
		end


		# result = BattleModel.calc_result(player, cave.monsters)
		# if result[:winner] == player
		# 	reward = cave.reward(stars)
		# 	player.get(reward)
		# 	result.merge(:reward => reward)
		# end
		# render_success(:data => result)
		@player.update_caves_info
		render_success(:report => result, :caves => @player.full_cave_stars_info)
	end

	def get_caves_info
		@player.update_caves_info
		render_success(:caves => @player.full_cave_stars_info)
	end
end
