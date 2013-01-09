class DinosaurController < ApplicationController
	before_filter :validate_dinosaur, :only => [:update, :hatch_speed_up, :feed, :heal, :rename, :reborn, :release]
	before_filter :validate_player, :only => [:food_list, :feed, :heal, :expand_capacity]

	def update
		@dinosaur.update_status!
		render :json => {:player => {:dinosaurs => [@dinosaur.to_hash]}}
	end

	def hatch_speed_up
		@player = @dinosaur.player
		if @dinosaur.hatch_speed_up!
			if !@player.beginning_guide_finished && @player.guide_cache[:hatch_speed_up].nil?
				cache = @player.guide_cache.merge(:hatch_speed_up => true)
				@player.set :guide_cache, cache.to_json
			end
		end

		render :json => {:player => @player.to_hash.merge({:dinosaurs => [@dinosaur.to_hash]})}
	end

	def feed
		food = @player.foods.find(:type => params[:food_type].to_i).first

		if (@dinosaur.hunger_time - @dinosaur.feed_point) < 10
			render :json => {:error => "BABY_IS_FULL"} and return
		end

		if food.nil? || food.count <= 0
			render :json => {:error => "NOT_ENOUGH_FOOD"} and return
		else
			@dinosaur.eat!(food)
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
		new_name = params[:name].to_s
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
end
