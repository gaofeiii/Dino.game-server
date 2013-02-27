class ShoppingController < ApplicationController
	before_filter :validate_player, :only => [:buy, :buy_gems]

	def buy_gems
		order = AppStoreOrder.find(:transaction_id => params[:transaction_id]).first
		if order.nil?
			order = AppStoreOrder.create 	:base64_receipt => params[:base64_receipt], 
																		:transaction_id => params[:transaction_id],
																		:player_id => @player.id
		end

		if order.validate!
			@player.get(:gems)
			render_success 	:player => @player.to_hash,
											:transaction_id => params[:transaction_id],
											:is_finished => true
		else
			render :json => {
				:message => "FAILED",
				:error_type => Error.types[:iap_error],
				:transaction_id => params[:transaction_id],
				:is_finished => true
			}
		end
	end

	def buy
		sid = params[:sid].to_i
		goods = Shopping.find_by_sid(sid)

		if goods.nil?
			render_error(Error::NORMAL, "Invalid serial id") and return
		end

		puts "--- sid: #{sid} ---"

		case goods[:goods_type]
		# Buy resources...
		when Shopping::GOODS_TYPE[:res]
			res_type = goods[:res_type]
			res_count = (goods[:count] * @player.tech_warehouse_size).to_i
			gems_cost = (res_count / goods[:count_per_gem].to_f).ceil

			if @player.spend!(:gems => gems_cost)
				@player.receive!(res_type => res_count)
			else
				render_error(Error::NORMAL, I18n.t("general.not_enough_gems")) and return
			end

		# Buy items...
		when Shopping::GOODS_TYPE[:item]
			# --- Food ---
			if @player.spend!(goods.slice(:gems))
				if goods[:item_category] == Item.categories[:food]
					food = @player.find_food_by_type(goods[:item_type])
					if food.nil?
						tmp = goods.slice(:item_category, :item_type).merge(:player_id => @player.id)
						# Item.create(tmp)
						Specialty.create(:category => goods[:item_category], :type => goods[:item_type], :count => goods[:count], :player_id => @player.id)
					else
						food.increase(:count, goods[:count])
					end
				else
					itm = goods.slice(:item_category, :item_type).merge(:player_id => @player.id)
					Item.create(itm)
				end
			else
				render_error(Error::NORMAL, I18n.t("general.not_enough_gems")) and return
			end

		# Buy eggs...
		when Shopping::GOODS_TYPE[:egg]
			if @player.spend!(goods.slice(:gems))
				egg = Shopping.buy_random_egg(:item_type => goods[:item_type], :player_id => @player.id)
				if egg
					render_success(:player => {:gems => @player.gems, :items => @player.items.find(:item_category => Item.categories[:egg])}) and return
				end
			else
				render_error(Error::NORMAL, I18n.t("general.not_enough_gems")) and return
			end
		end

		render_success :player => @player.to_hash(:resources, :items, :specialties)
	end

end
