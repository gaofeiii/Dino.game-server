class ItemsController < ApplicationController
	before_filter :validate_player
	before_filter :validate_item, :only => [:use]

	def my_items_list
		render :json => {:player => {:items => @player.items.map{|item| item.to_hash}}}
	end

	def use
		if @item.item_category == ITEM_CATEGORY[:egg]
			if @player.dinosaurs.size >= @player.dinosaurs_capacity
				render_error(Error::NORMAL, "NOT_ENOUGH_SPACE") and return
			end

			obj = @item.use!(:building_id => params[:building_id])

			if !@player.beginning_guide_finished && !@player.guide_cache[:has_hatched_dino]
				cache = @player.guide_cache.merge('has_hatched_dino' => true)
				@player.set :guide_cache, cache.to_json
			end

			if !@player.finish_daily_quest
				@player.daily_quest_cache[:hatch_dinosaurs] ||= 0
				@player.daily_quest_cache[:hatch_dinosaurs] += 1
				@player.set :daily_quest_cache, @player.daily_quest_cache.to_json
			end
		else
			render_error(Error::NORMAL, "ITEMS_NOT_DEFINED") and return
		end
		
		render :json => {:player => @player.to_hash(:dinosaurs, :items)}
	end

	def food_list
		render :json => {:player => {:dinosaurs => @player.dinosaurs_info, :food => @player.food_list}}
	end

	def scrolls_list
		render :json => {:player => {:scrolls => @player.items.find(:type => 3)}}
	end

	def eggs_list
		render :json => {:player => {:scrolls => @player.items.find(:type => 1)}}
	end

end
