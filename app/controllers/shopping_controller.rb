class ShoppingController < ApplicationController
	before_filter :validate_player, :only => [:buy, :buy_gems]

	def buy_resource
		
	end

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

		if @player.spend!(goods.slice(:gems))
			case goods[:goods_type]
			when Shopping::GOODS_TYPE[:res]
				tmp = goods.slice(:stone, :wood, :gold_coin)
				@player.receive!(tmp)
			when Shopping::GOODS_TYPE[:item]
				if goods[:item_category] == ITEM_CATEGORY[:specialty]
					food = @player.find_food_by_type(goods[:item_type])
					if food.nil?
						tmp = goods.slice(:item_category, :item_type).merge(:player_id => @player.id)
						Item.create(tmp)
					else
						food.increase(:count, goods[:count])
					end
				else
					tmp = goods.slice(:item_category, :item_type).merge(:player_id => @player.id)
					Item.create(tmp)
				end
				
			end
			render_success :player => @player.to_hash(:resources, :items, :specialties)
		else
			render_error Error::NORMAL, "Not enough gems"
		end
	end

end
