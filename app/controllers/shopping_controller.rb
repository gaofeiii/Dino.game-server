class ShoppingController < ApplicationController
	before_filter :validate_player, :only => [:buy, :buy_gems, :buy_arena_count]

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
			res_count = goods[:count]
			gems_cost = goods[:gems]

			if @player.spend!(:gems => gems_cost)
				@player.receive!(res_type => res_count)

				Stat.record_gems_consume(:type => :buy_resource, :times => 1, :count => gems_cost)

				render_success(:player => @player.resources)
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

					Stat.record_gems_consume(:type => :buy_food, :times => 1, :count => goods.slice(:gems)[:gems])

					render_success(:player => @player.to_hash(:food)) and return
				else
					itm = goods.slice(:item_category, :item_type, :count).merge(:player_id => @player.id)
					Item.create(itm)

					record_type = case goods[:item_category]
					when 3
						:buy_scroll
					when 4
						:buy_vip
					when 5
						:buy_protection
					when 6
						:buy_lottery
					end

					Stat.record_gems_consume(:type => record_type, :times => 1, :count => goods.slice(:gems)[:gems])

					render_success(:player => @player.to_hash(:items)) and return
				end
			else
				render_error(Error::NORMAL, I18n.t("general.not_enough_gems")) and return
			end

		# Buy eggs...
		when Shopping::GOODS_TYPE[:egg]
			if @player.spend! goods.slice(:gems, :gold, :gold_coin)
				egg = Shopping.buy_random_egg(:sid => sid, :player_id => @player.id)

				# === Guide ===
				if @player.has_beginner_guide?
					@player.cache_beginner_data(:has_bought_egg => true)
					egg.update :quality => 3, :item_type => 3
				end
				# === End of Guide ===

				# Recording...
				if goods[:gems].to_i > 0
					Stat.record_gems_consume(:type => :buy_egg, :times => 1, :count => goods[:gems])
				end

				if goods[:gold].to_i > 0
					Stat.record_gold_consume(:type => :buy_egg, :times => 1, :count => goods[:gold])
				end

				if egg
					render_success(:player => @player.to_hash(:items)) and return
				end
			else
				render_error(Error::NORMAL, I18n.t("general.not_enough_gems_or_gold")) and return
			end
		end
	end

	def buy_arena_count
		
		if @player.spend!(:gems => Shopping::MATCH_COUNT_COST)
			@player.set :honour_battle_count, @player.total_honour_count
			Stat.record_gems_consume(:type => :buy_arena, :times => 1, :count => Shopping::MATCH_COUNT_COST)
			render_success(:todays_count => @player.todays_count, :gems => @player.gems)
		else
			render_error(Error::NORMAL, I18n.t("general.not_enough_gems"))
		end
	end

end
