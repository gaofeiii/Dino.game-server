class DinosaurController < ApplicationController
	before_filter :validate_dinosaur, :only => [:update, :hatch_speed_up, :feed]
	before_filter :validate_player, :only => [:food_list, :feed]

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
			if !@player.beginning_guide_finished && !@player.guide_cache[:feed_dino]
				cache = @player.guide_cache.merge(:feed_dino => true)
				@player.set :guide_cache, cache
			end
		end
		render :json => {
			:player => @player.to_hash(:dinosaurs, :food)
		}
	end
end
