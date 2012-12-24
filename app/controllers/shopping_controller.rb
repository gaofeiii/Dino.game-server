class ShoppingController < ApplicationController
	before_filter :validate_player, :only => [:buy]

	def buy_resource
		
	end

	def buy_gems
		
	end

	def buy
		sid = params[:sid].to_i
		goods = Shopping.find_by_sid(sid)

		if goods.nil?
			render_error(Error.types[:normal], "Invalid serial id") and return
		end

		if @player.spend!(goods.slice(:sun))
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
			render_error Error.types[:normal], "Not enough gems"
		end
	end

end
