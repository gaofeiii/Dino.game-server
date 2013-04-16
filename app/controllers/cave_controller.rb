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

				if dino.player_id.to_i == @player.id
					render_error(Error::NORMAL, I18n.t('strategy_error.dino_is_hungry')) and return if dino.feed_point <= 5
					render_error(Error::NORMAL, I18n.t('strategy_error.dino_hp_is_zero')) and return if dino.current_hp < dino.total_hp * 0.1
				end
				
				dino
			else
				nil
			end
		end.compact

		scroll = Item[params[:scroll_id]]
		scroll_type = scroll.try(:item_type).to_i

		attacker = {
			:player => @player,
			:owner_info => {
				:type => 'Player',
				:id => @player.id,
				:name => @player.nickname,
				:avatar_id => @player.avatar_id
			},
			:buff_info => [],
			:scroll_type => scroll_type,
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

		player_dinos.each do |dino|
			dino.consume_energy(:energy => 80)
		end

		# 主线：使用卷轴
		if scroll
			@player.serial_tasks_data[:use_scroll] ||= 0
			@player.serial_tasks_data[:use_scroll] = 1
			@player.set :serial_tasks_data, @player.serial_tasks_data
			scroll.use!
		end

		result = BattleModel.cave_attack(attacker, defender)

		rounds_count = result[:all_rounds].size

		stars = PlayerCave.cave_rounds_stars(rounds_count)

		reward = {}
		default_reward = {:wood => @cave.index * 10, :stone => @cave.index * 15}

		if result[:winner] == 'attacker'
			
			all_star_rewards = @cave.all_star_rewards
			case stars
			when 1
				reward = all_star_rewards[1]
			when 2
				reward = all_star_rewards[2] if Tool.rate(@cave.star_2_chance)
			when 3
				unless @cave.get_perfect_reward
					reward = all_star_rewards[3]
					@cave.get_perfect_reward = true
				else
					reward = all_star_rewards[3] if Tool.rate(@cave.star_3_chance)
				end
			end

			reward = default_reward if reward.blank?

			rwd = nil

			if !reward[:item_cat].nil?
				result[:reward][:items] ||= []
				result[:reward][:items] << reward
				rwd = Reward.new :item => reward
			else
				result[:reward] = reward
				rwd = Reward.new reward
			end

			@player.get_reward(rwd)

			# === Guide ===
			if @player.has_beginner_guide?
				@player.cache_beginner_data(:has_attacked_cave => true)
			end
			# === End of Guide ===

			@cave.todays_count += 1
			@cave.stars = stars if @cave.stars < stars
			@cave.save
		end

		@player.update_caves_info

		result[:reward][:dino_rewards] = attacker[:army].map do |dino|
			{
				:id => dino.id,
				:exp_inc => 100,
				:is_upgraded => [true, false].sample
			}
		end

		render_success(:report => result, :caves => @player.full_cave_stars_info)
	end

	def get_caves_info
		@player.update_caves_info
		render_success(:caves => @player.full_cave_stars_info)
	end
end
