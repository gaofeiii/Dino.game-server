class ItemsController < ApplicationController
	before_filter :validate_player
	before_filter :validate_item, :only => [:use, :lucky_reward]

	def my_items_list
		render :json => {:player => {:items => @player.items.map{|item| item.to_hash}}}
	end

	def use
		if @item.item_category == Item.categories[:egg]
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
		elsif @item
			
		else
			render_error(Error::NORMAL, "ITEMS_NOT_DEFINED") and return
		end
		
		render_success :player => @player.to_hash(:dinosaurs, :items)
	end

	def food_list
		render_success :player => {:dinosaurs => @player.dinosaurs_info, :food => @player.food_list}
	end

	def scrolls_list
		render_success :player => {:scrolls => @player.items.find(:item_category => 3)}
	end

	def eggs_list
		render_success :player => {:items => @player.items.find(:item_category => 1)}
	end

	def special_items_list
		render_success :player => {:items => @player.special_items}
	end

	def lucky_reward
		if @item.use
			rwd = LuckyReward.lucky_reward.get_one
			render_success :reward => rwd
		else
			render_error(Error::NORMAL, "Item has already used")
		end
	end

end
