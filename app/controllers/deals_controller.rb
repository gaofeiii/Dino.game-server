class DealsController < ApplicationController
	before_filter :validate_player, :only => [:buy, :sell, :my_selling_list, :my_items_list]

	def list
		# deals = Deal.all.sort_by(:created_at, :order => 'DESC', :limit => [0, 20])
		# render_success(:deals => deals)
		cat = params[:cat].to_i
		deals = []
		if cat.zero?
			deals = Deal.find(:status => Deal::STATUS[:selling]).sort_by(:created_at, :order => 'DESC', :limit => [0, 20])
		else
			page = params[:page].to_i
		deals = Deal.find(:status => Deal::STATUS[:selling], :category => cat).sort_by(:created_at, :order => 'DESC', :limit => [page, 20])
		end

		render_success(:deals => deals)
	end

	def buy
		deal = Deal[params[:deal_id]]

		if deal.nil? || deal.status == Deal::STATUS[:closed]
			render_error(Error::NORMAL, I18n.t('deals_error.trade_has_close')) and return
		end

		if deal.seller_id.to_i == @player.id
			render_error(Error::NORMAL, I18n.t('deals_error.cannot_buy_self_goods')) and return
		end

		deal.mutex(0.5) do
			case deal.category
			when Deal::CATEGORIES[:res]
				goods = if deal.type == Deal::RES_TYPES[:wood]
					{:wood => deal.count}
				elsif deal.type == Deal::RES_TYPES[:stone]
					{:stone => deal.count}
				else
					{}
				end

				if !goods.blank?
					cost = {:gold_coin => deal.price.to_i}

					if @player.spend!(cost)
						@player.receive!(goods)
						deal.seller.receive!(cost)
					else
						render_error(Error::NORMAL, I18n.t("general.not_enough_gold")) and return
					end
				end
			when Deal::CATEGORIES[:egg]
				i = Item[deal.gid]
				i.update :player_id => @player.id
				deal.seller.receive!(:gold => deal.price.to_i)
			when Deal::CATEGORIES[:food]
				food = @player.foods.find(:type => deal.type).first
				return nil if food.nil?
				food.increase(:count, deal.count)
				deal.seller.receive!(:gold => deal.price.to_i)
			else
				render_error(Error::NORMAL, "INVALID_ITEM_CATE") and return
			end

			seller = deal.seller
			Mail.create_deal_succses_mail :receiver_name => seller.nickname,
																		:receiver_id => seller.id,
																		:buyer => @player.nickname,
																		:gold => deal.price.to_i,
																		:goods_name => deal.goods_name(seller.locale),
																		:count => deal.count,
																		:locale => seller.locale
			deal.delete
		end
		render_success(:player => @player.to_hash(:resources), :deal_id => deal.id)
	end

	def sell
		goods_cat = params[:cat]
		goods_type = params[:type]

		price = params[:price].to_f

		if price > 999999
			render_error(Error::NORMAL, I18n.t('deals_error.price_too_high')) and return
		end

		case goods_cat
		when Deal::CATEGORIES[:res]
			type = params[:type]
			res_name = if type == 1
				'wood'
			elsif type == 2
				'stone'
			else
				nil
			end
			count = params[:count].to_i
			

			error = if res_name.nil? || count <= 0 || price <= 0.0
				"INVALID_RES_TYPE"
			elsif count <= 0
				I18n.t('deals_error.count_must_more_than_zero')
			elsif price <= 1
				I18n.t('deals_error.price_must_more_than_zero')
			else
				nil
			end
			if error
				render_error(Error::NORMAL, error) and return
			end

			if @player.spend!(res_name => count)
				Deal.create :status => Deal::STATUS[:selling],
										:category => goods_cat,
										:type => goods_type,
										:count => count,
										:price => price,
										:end_time => Time.now.to_i + 3.days,
										:seller_id => @player.id
			end
		when Deal::CATEGORIES[:egg]
			gid = params[:gid]
			egg = Item[gid]
			if egg.nil?
				render_error(Error::NORMAL, "INVALID_ITEM_ID") and return
			end
			if !egg.is_egg?
				render_error(Error::NORMAL, "It is not a egg") and return
			end
			if egg.player_id.blank?
				render_error(Error::NORMAL, I18n.t('deals_error.already_sold')) and return
			end

			if Deal.create  :status => Deal::STATUS[:selling],
											:category => goods_cat,
											:type => egg.item_type,
											:count => 1,
											:price => price,
											:gid => gid,
											:end_time => Time.now.to_i + 3.days,
											:seller_id => @player.id
				egg.update :player_id => nil
			end
		when Deal::CATEGORIES[:food]
			type = params[:type].to_i
			count = params[:count].to_i

			error = if !type.in?(Dinosaur.const.keys)
				"INVALID_EGG_TYPE"
			elsif count <= 0
				I18n.t('deals_error.count_must_more_than_zero')
			else
				nil
			end
			if error
				render_error(Error::NORMAL, error) and return
			end

			food = @player.foods.find(:type => type).first
			if food.nil? || food.count < count
				render_error(Error::NORMAL, I18n.t('general.not_enough_food')) and return
			else
				food.increase(:count, -count)

				Deal.create :status => Deal::STATUS[:selling],
										:category => goods_cat,
										:type => food.type,
										:count => count,
										:price => price,
										:gid => gid,
										:end_time => Time.now.to_i + 3.days,
										:seller_id => @player.id
			end
		end

		render_success(:player => @player.to_hash(:resources, :items, :specialties))
	end

	def my_items_list
		render_success(:player => @player.to_hash(:resources, :items, :specialties))
	end

	def my_selling_list
		render_success(:deals => @player.deals)
	end

	def cancel_deal
		deal = Deal[params[:deal_id]]
		if !deal.nil?
			deal.cancel!
			render_success(:deals => deal.seller.deals.to_a)
		end
	end
end
