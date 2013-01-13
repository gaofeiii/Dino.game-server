class DealsController < ApplicationController
	before_filter :validate_player, :only => [:buy, :sell, :my_selling_list, :my_items_list]

	def list
		# deals = Deal.all.sort_by(:created_at, :order => 'DESC', :limit => [0, 20])
		# render_success(:deals => deals)
		cat = params[:cat]
		if cat.zero?
			cat = 1
		end
		page = params[:page].to_i
		deals = Deal.find(:status => Deal::STATUS[:selling], :category => cat).sort_by(:created_at, :order => 'DESC', :limit => [page, 20])
		render_success(:deals => deals)
	end

	def buy
		deal = Deal[params[:deal_id]]

		if deal.nil? || deal.status == Deal::STATUS[:closed]
			render_error(Error::NORMAL, "Trade has been finished") and return
		end

		deal.mutex(0.5) do
			case deal.category
			when Deal::CATEGORIES[:res]
				goods = if deal.type = Deal::RES_TYPES[:wood]
					{:wood => deal.count}
				elsif deal.type = Deal::RES_TYPES[:stone]
					{:stone => deal.count}
				else
					{}
				end
				p "======== goods: ", goods
				if !goods.blank?
					# p "--- deal.price: #{deal.price.to_i}"
					cost = {:gold_coin => deal.price.to_i}
					p "cost", cost
					@player.spend!(cost)
					@player.receive!(goods)
				end
			when Deal::CATEGORIES[:egg]
				i = Item[deal.gid]
				i.update :player_id => @player.id
			when Deal::CATEGORIES[:food]
				food = @player.foods.find(:type => deal.type).first
				return nil if food.nil?
				food.increase(:count, deal.count)
			else
				render_error(Error::NORMAL, "Invalid cate id") and return
			end

			# deal.set :status, Deal::STATUS[:closed]
			deal.delete
		end
		render_success(:player => @player.to_hash(:resources, :items))
	end

	def sell
		goods_cat = params[:cat]
		goods_type = params[:type]

		price = params[:price].to_f

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
				"invalid resource type"
			elsif count <= 0
				"count should be more than zero"
			elsif price <= 0.0
				"price shoudl be more than zero"
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
										:price => price * count,
										:end_time => Time.now.to_i + 3.days,
										:seller_id => @player.id
			end
		when Deal::CATEGORIES[:egg]
			gid = params[:gid]
			egg = Item[gid]
			if egg.nil?
				render_error(Error::NORMAL, "Invalid Item Id") and return
			end
			if !egg.is_egg?
				render_error(Error::NORMAL, "It is not a egg") and return
			end

			Deal.create :status => Deal::STATUS[:selling],
									:category => goods_cat,
									:type => egg.item_type,
									:count => 1,
									:price => price,
									:gid => gid,
									:end_time => Time.now.to_i + 3.days,
									:seller_id => @player.id
		when Deal::CATEGORIES[:food]
			type = params[:type].to_i
			count = params[:count].to_i

			error = if !type.in?(Dinosaur.const.keys)
				"Invalid egg type"
			elsif count <= 0
				"count should be more than zero"
			else
				nil
			end
			if error
				render_error(Error::NORMAL, error) and return
			end

			food = @player.foods.find(:type => type).first
			if food.nil? || food.count < count
				render_error(Error::NORMAL, "Not enough food") and return
			else
				food.increase(:count, -count)
				Deal.create :status => Deal::STATUS[:selling],
										:category => goods_cat,
										:type => food.type,
										:count => count,
										:price => price * count,
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
