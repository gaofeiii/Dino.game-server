class DinosaurController < ApplicationController
	before_filter :validate_dinosaur, :only => [:update, :hatch_speed_up, :feed, :heal, :rename, :reborn, :release]
	before_filter :validate_player, :only => [:food_list, :feed, :heal, :expand_capacity, :refresh_all_dinos, :training]

	def update
		@dinosaur.update_status!
		render :json => {:player => {:dinosaurs => [@dinosaur.to_hash]}}
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

		if (@dinosaur.hunger_time - @dinosaur.feed_point) < 10
			render :json => {:error => "BABY_IS_FULL"} and return
		end

		if food.nil? || food.count <= 0 || count > food.count
			render_error(Error::NORMAL, I18n.t('dinosaur_error.not_enough_food')) and return
		else
			@dinosaur.eat!(food, count)
			if !@player.beginning_guide_finished && !@player.guide_cache['feed_dino']
				cache = @player.guide_cache.merge('feed_dino' => true)
				@player.set :guide_cache, cache
			end
		end
		render :json => {
			:player => @player.to_hash(:dinosaurs, :food)
		}
	end

	def heal
		if @player.spend!(@dinosaur.heal_speed_up_cost)
			if !@player.beginning_guide_finished && !@player.guide_cache['heal_dino']
				cache = @player.guide_cache.merge('heal_dino' => true)
				@player.set :guide_cache, cache
			end
			@dinosaur.heal_speed_up!
		end
		render_success(:player => @player.to_hash(:dinosaurs))
	end

	def rename
		new_name = params[:new_name].to_s
		if new_name.sensitive?
			render_error(Error::NORMAL, "INVALID_DINO_NAME") and return
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
			render_error(Error::NORMAL, "CANNOT_RELEASE_HATCHING_DINO") and return
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
			render_error(Error::NORMAL, "NOT_ENOUGH_GEMS")
		end
	end

	def refresh_all_dinos
		render_success(:player => {:dinosaurs => @player.dinosaurs_info})
	end

	def training
		@dinosaur = Dinosaur[params[:dinosaur_id]]
		
		if @player.spend!(:gold => 100)
			@dinosaur.increase(:growth_point, 10)
			render_success(:growth_point => @dinosaur.growth_point)
		else
			render_error(Error::NORMAL, "Not enough gold")
		end
	end
end
