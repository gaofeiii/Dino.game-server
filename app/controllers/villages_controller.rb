class VillagesController < ApplicationController

	before_filter :validate_village, :only => [:index, :move]

	def index
		player = Player[params[:player_id]]

		unless player
			render :json => "Player not found", :status => 999 and return
		end
		data = {:message => "OK", :player => player.to_hash(:all)}
		render :json => player.village
	end

	def move
		player = @village.player

		if player.spend!(:gems => 50)
			@village.update :x => params[:x], :y => params[:y], :index => 0
			render_success(:player => player.to_hash.merge(:village => @village.to_hash))
		else
			render_error(Error::NORMAL, "NOT_ENOUGH_GEMS")
		end
	end

	def visit_info
		friend = Player[params[:friend_id]]

		if friend
			render_success(:friend => friend.visit_info)
		else
			render_error(Error::NORMAL, "friend not found")
		end
	end

	def steal
		@building = Building[params[:building_id]]

		if @building.nil?
			render_error(Error::NORMAL, "Invalid building id") and return
		end

		@village = @building.village

		if @village.last_stolen_time >= Time.now.beginning_of_day.to_i && @village.stolen_count >= Village::MAX_STEAL_TIME
			render_error(Error::NORMAL, "This player has been stolen for 3 times. Try it tomorrow :)") and return
		end

		if @building.is_resource_building?
			@building.update_harvest!

			if @building.harvest_count > 10
				@player = Player[params[:player_id]]
				count = @building.harvest_count / 10

				if @building.is_lumber_mill? || @building.is_quarry?
					res = Resource::TYPE[@building.harvest_type]
					@player.receive!(res => count)
					@building.set :harvest_count, @building.harvest_count - count
				elsif @building.is_collecting_farm? || @building.is_hunting_field?
					@player.receive_food!(@building.harvest_type, count)
					@building.set :harvest_count, @building.harvest_count - count
				end
				render_success(:count => count)
			else
				render_error(Error::NORMAL, "harvest not finished") and return
			end
		else
			render_error(Error::NORMAL, "not a resource building")
		end
	end

end
