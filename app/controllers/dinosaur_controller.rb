class DinosaurController < ApplicationController
	before_filter :validate_dinosaur

	def update
		@dinosaur.update_status!
		render :json => {:player => {:dinosaurs => [@dinosaur.to_hash]}}
	end

	def hatch_speed_up
		@dinosaur.hatch_speed_up!
		render :json => {:player => {:dinosaurs => [@dinosaur.to_hash]}}
	end
end
