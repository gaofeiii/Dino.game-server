class ItemsController < ApplicationController
	before_filter :validate_player
	before_filter :validate_item, :only => [:lucky_reward, :drop]

	def my_items_list
		render :json => {:player => {:items => @player.items.map{|item| item.to_hash}}}
	end

	def use
		@item = Item[params[:item_id]]

		if @item.nil?
			render_error(Error::NORMAL, I18n.t('items.invalid_item_id')) and return
		end
		
		# ==== If using egg ====
		if @item.item_category == Item.categories[:egg]
			render_error(Error::NORMAL, "Hatch egg in Incubation") and return
			
		# ==== If using lottery ====
		elsif @item.item_category == Item.categories[:lottery]
			rwd = LuckyReward.rand_one(@item.item_type)
			@player.receive_lucky_reward(rwd)
			@item.delete
			render_success 	:reward => rwd, 
											:category => @item.item_category,
											:player => @player.to_hash(:items)
			return
		# ==== End lottery ====

		# ==== Using VIP ====
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
			vip_left_time = @player.vip_expired_time - ::Time.now.to_i
			render_success(:player => @player.to_hash(:dinosaurs, :items), :info => I18n.t('general.use_vip_success', :vip_left_time => vip_left_time / 3600))
		# ==== End VIP ====
		elsif @item.item_category == Item.categories[:protection]
			vil = Village.new(:id => @player.village_id).gets(:protection_until)
			now_time = ::Time.now.to_i
			add_time = if @player.is_vip?
				12.hours
			else
				6.hours
			end
			if vil.protection_until < now_time
				vil.set :protection_until, now_time + add_time
			else
				vil.set :protection_until, vil.protection_until + add_time
			end
			@item.delete
			protect_left_time = vil.protection_until - ::Time.now.to_i
			render_success(:player => @player.to_hash(:village, :items), :info => I18n.t('general.use_protect_success', :protect_left_time => protect_left_time / 3600)) and return
		else
			render_error(Error::NORMAL, "ITEMS_NOT_DEFINED") and return
		end
		
		
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
