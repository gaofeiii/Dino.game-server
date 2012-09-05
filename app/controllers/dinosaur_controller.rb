class DinosaurController < ApplicationController
	before_filter :validate_dinosaur, :only => [:update, :hatch_speed_up, :feed]
	before_filter :validate_player, :only => [:food_list, :feed]

	def update
		@dinosaur.update_status!
		render :json => {:player => {:dinosaurs => [@dinosaur.to_hash]}}
	end

	def hatch_speed_up
		@dinosaur.hatch_speed_up!
		render :json => {:player => {:dinosaurs => [@dinosaur.to_hash]}}
	end

	def feed
		food = @player.specialties.find(:type => params[:food_type].to_i).first
		if food.count <= 0
			render :json => {:error => "NOT_ENOUGH_FOOD"} and return
		else
			@dinosaur.eat!(food)	
		end
		render :json => {:player => {:dinosaurs => [@dinosaur.to_hash]}}
	end

	def food_list
		render :json => {:player => {:food => @player.food_list}}
	end
end
