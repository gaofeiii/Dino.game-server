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

			sid = Shopping.find_sid_by_product_id(order.product_id)

			if sid && @player.first_purchase_reward[sid].blank?
				reward = Shopping.find_first_reward_by_sid(sid)
				@player.receive_reward!(reward)
				@player.first_purchase_reward[sid] = 1
				@player.set :first_purchase_reward, @player.first_purchase_reward.to_json
			end

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
			render_error(Error::NORMAL, "INVALID_SID") and return
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
				render_success(:player => @player.to_hash)
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
					render_success(:player => @player.to_hash(:specialties)) and return
				else
					itm = goods.slice(:item_category, :item_type).merge(:player_id => @player.id)
					Item.create(itm)
					render_success(:player => @player.to_hash(:items)) and return
				end
			else
				render_error(Error::NORMAL, I18n.t("general.not_enough_gems")) and return
			end

		# Buy eggs...
		when Shopping::GOODS_TYPE[:egg]
			if @player.spend!(goods.slice(:gems))
				egg = Shopping.buy_random_egg(:item_type => goods[:item_type], :player_id => @player.id)

				# === Guide ===
				@player.gets :guide_cache, :beginning_guide_finished

				if !@player.beginning_guide_finished && !@player.guide_cache[:buy_egg]
					cache = @player.guide_cache.merge(:buy_egg => true)
					@player.set :guide_cache, cache
					egg.update :quality => 3, :item_type => 1
				end

				if @player.has_beginner_guide?
					@player.cache_beginner_data(:has_bought_egg => true)
				end
				# === End of Guide ===

				if egg
					render_success(:player => @player.to_hash(:items)) and return
				end
			else
				render_error(Error::NORMAL, I18n.t("general.not_enough_gems")) and return
			end
		end
	end

end
