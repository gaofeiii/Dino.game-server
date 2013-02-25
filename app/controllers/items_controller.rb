class ItemsController < ApplicationController
	before_filter :validate_player
	before_filter :validate_item, :only => [:use, :lucky_reward, :drop]

	def my_items_list
		render :json => {:player => {:items => @player.items.map{|item| item.to_hash}}}
	end

	def use
		# ==== If using egg ====
		if @item.item_category == Item.categories[:egg]
			render_error(Error::NORMAL, "Hatch egg in Incubation") and return
			
		# ==== If using lottery ====
		elsif @item.item_category == Item.categories[:lottery]
			rwd = LuckyReward.rand_one(@item.item_type)
			render_success(:reward => rwd, :category => @item.item_category) and return

		elsif @item.item_category == Item.categories[:vip]
			@player.player_type = Player::TYPE[:vip]
			now = Time.now.to_i
			if now > @player.vip_expired_time
				@player.vip_expired_time = now + 1.month.to_i
			else
				@player.vip_expired_time += 1.month.to_i
			end
			@player.save
			@item.delete
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

	def drop
		@item.delete
		render_success
	end

end
