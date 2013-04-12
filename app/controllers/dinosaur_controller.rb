class DinosaurController < ApplicationController
	before_filter :validate_dinosaur, :only => [:update, :hatch_speed_up, :feed, :heal, :rename, :reborn, :release]
	before_filter :validate_player, :only => [:hatch, :food_list, :feed, :heal, :expand_capacity, :refresh_all_dinos, :refresh_all_dinos_with_advisor, :training, :evolution]

	def update
		@dinosaur.update_status!
		render :json => {:player => {:dinosaurs => [@dinosaur.to_hash]}}
	end

	def hatch
		if @player.dinosaurs.size >= @player.dinosaurs_capacity + @player.tech_dinosaurs_size
			render_error(Error::NORMAL, I18n.t('dinosaur_error.not_enough_space')) and return
		end

		@egg = Item[params[:egg_id]]

		if @egg.nil?
			render_error(Error::NORMAL, I18n.t('dinosaur_error.egg_already_hatched')) and return
		end

		if not @egg.is_egg?
			render_error(Error::NORMAL, I18n.t('dinosaur_error.not_a_egg')) and return
		end

		@building = Building[params[:building_id]]# || @player.buildings.find(:type => 6).first

		if @building.nil?
			render_error(Error::NORMAL, I18n.t('dinosaur_error.must_be_hatched_in_cuba')) and return
		end

		if @egg.use!(:building_id => @building.id)
			if !@player.beginning_guide_finished && !@player.guide_cache[:has_hatched_dino]
				cache = @player.guide_cache.merge(:has_hatched_dino => true)
				@player.set :guide_cache, cache
			end

			

			render_success({:player => @player.to_hash(:dinosaurs), :egg_id => @egg.id})
		else
			render_error(Error::NORMAL, "Unknown_Error_On_Hatching_Egg")
		end
	end

	def hatch_speed_up
		@player = @dinosaur.player
		if @player.spend!(:gems => @dinosaur.hatch_speed_up_cost_gems)
			if @dinosaur.hatch_speed_up!
				if !@player.beginning_guide_finished && @player.guide_cache[:hatch_speed_up].nil?
					cache = @player.guide_cache.merge(:hatch_speed_up => true)
					@player.set :guide_cache, cache.to_json
				end
			end
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gems')) and return
		end
		
		render :json => {:player => @player.to_hash.merge({:dinosaurs => [@dinosaur.to_hash]})}
	end

	def feed
		food = @player.foods.find(:type => params[:food_type].to_i).first
		count = params[:food_count].to_i
		count = count > 0 ? count : 1

		hunger_point = @dinosaur.hunger_time - @dinosaur.feed_point
		if (hunger_point) < 10
			render :json => {:error => I18n.t('dinosaur_error.dinosaur_is_full')} and return
		end

		if food.nil? || food.count <= 0 || count > food.count
			render_error(Error::NORMAL, I18n.t('dinosaur_error.not_enough_food')) and return
		else
			@dinosaur.eat!(food, count)
			if !@player.beginning_guide_finished && !@player.guide_cache[:feed_dino]
				cache = @player.guide_cache.merge('feed_dino' => true)
				@player.set :guide_cache, cache
			end

			if @player.has_beginner_guide?
				@player.cache_beginner_data(:has_fed_dino => true)
			end
		end

		data = {
			:player => {
				:dinosaurs => [@dinosaur.to_hash],
				:food => @player.specialties.map{|s| s.to_hash}
			}
		}
		render :json => data
		# render :json => {
		# 	:player => @player.to_hash(:dinosaurs, :specialties)
		# }
	end

	def heal
		if @player.spend!(@dinosaur.heal_speed_up_cost)
			if !@player.beginning_guide_finished && !@player.guide_cache[:heal_dino]
				cache = @player.guide_cache.merge('heal_dino' => true)
				@player.set :guide_cache, cache
			end

			if @player.has_beginner_guide?
				@player.cache_beginner_data(:has_healed_dino => true)
			end
			
			@dinosaur.heal_speed_up!
		end
		render_success(:player => @player.to_hash(:dinosaurs))
	end

	def rename
		new_name = params[:new_name].to_s
		if new_name.sensitive?
			render_error(Error::NORMAL, I18n.t('dinosaur_error.invalid_dino_name')) and return
		end

		@dinosaur.set :name, new_name
		data = {
			:player => {
				:dinosaurs => [@dinosaur.to_hash]
			}
		}
		render_success(data)
	end

	def reborn
		@dinosaur.init_atts.save
		data = {
			:player => {
				:dinosaurs => [@dinosaur.to_hash]
			}
		}
		render_success(data)
	end

	def release
		if @dinosaur.status == Dinosaur::STATUS[:egg]
			render_error(Error::NORMAL, I18n.t('dinosaur_error.cannot_release_hatching_dino')) and return
		end

		Ohm.redis.sadd("Player:#{@dinosaur.player_id}:released_dinosaurs", @dinosaur.id)
		@dinosaur.update :player_id => nil
		render_success(:dinosaur_id => @dinosaur.id)
	end

	def expand_capacity
		if @player.spend!(:gems => @player.next_dino_space_gems)
			@player.increase :dinosaurs_capacity
			render_success(:player => @player.to_hash)
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gems'))
		end
	end

	def refresh_all_dinos
		render_success(:player => {:dinosaurs => @player.dinosaurs_info})
	end

	def refresh_all_dinos_with_advisor
		render_success(:player => {:dinosaurs => @player.dinosaurs_info, :advisor_dino => Dinosaur[9].to_hash})
	end

	def training
		@dinosaur = Dinosaur[params[:dinosaur_id]]

		train_attr = case params[:type]
		when 1
			:attack
		when 2
			:defense
		when 3
			:agility
		end

		# if @dinosaur.growth_point >= @dinosaur.max_growth_point
		# 	render_error(Error::NORMAL, I18n.t('dinosaur_error.reach_max_growth_point')) and return
		# end

		if @dinosaur.growth_times > @dinosaur.max_growth_times
			render_error(Error::NORMAL, I18n.t('dinosaur_error.reach_max_growth_point')) and return
		end
		
		if @player.spend!(:gold => @dinosaur.training_cost)
			@player.serial_tasks_data[:trained_dino] ||= 0
			@player.serial_tasks_data[:trained_dino] += 1
			@player.set :serial_tasks_data, @player.serial_tasks_data

			@dinosaur.training!(train_attr)
			render_success 	:growth_point => @dinosaur.growth_times,
											:max_growth_point => @dinosaur.max_growth_times,
											:attack => @dinosaur.total_attack,
											:defense => @dinosaur.total_defense,
											:speed => @dinosaur.speed,
											:gold_coin => @player.gold_coin
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gold'))
		end
	end

	def evolution
		target_egg = Item[params[:egg_id]]
		render_error(Error::NORMAL, 'Egg disappear!!!') and return unless target_egg

		source_eggs = params[:source_eggs].map{ |egg_id| Item[egg_id] }.compact
		render_error(Error::NORMAL, 'No egg to use!!!') and return if source_eggs.blank?

		total_evolution = source_eggs.sum{ |egg| egg.supply_evolution }.to_i
		target_egg.increase(:evolution_exp, total_evolution)
		target_egg.update_evolution
		source_eggs.map(&:delete)

		@player.serial_tasks_data[:egg_evolution] ||= 0
		@player.serial_tasks_data[:egg_evolution] += 1
		@player.set :serial_tasks_data, @player.serial_tasks_data

		render_success(:egg => target_egg.to_hash)
	end
end













