class DealsController < ApplicationController
	before_filter :validate_player, :only => [:buy, :sell]

	def list
		deals = Deal.all.sort_by(:created_at, :order => 'DESC', :limit => [0, 20])
		render_success(:deals => deals)
	end

	def buy
		deal = Deal[params[:deal_id]]

		if deal.nil? || deal.status == Deal::STATUS[:closed]
			render_error(Error.types[:normal], "Trade has been finished") and return
		end

		deal.mutex(0.5) do
			goods = case deal.type
			when Deal::TYPES[:res]
				if deal.res_type = Deal::RES_TYPES[:wood]
					{:wood => deal.count}
				elsif deal.res_type = Deal::RES_TYPES[:stone]
					{:stone => deal.count}
				else
					{}
				end
			when Deal::TYPES[:egg]
				Item[deal.gid]
			end
			@player.receive!(goods)
			deal.set :status, Deal::STATUS[:closed]
		end
		render_success(:player => @player.to_hash(:resources, :items))
	end

	def sell
		g_type = params[:type].to_i
		goods = case g_type
		when Deal.types[:res]
			if params[:res_type] == Deal::TYPES[:wood]
				{:wood => params[:count].to_i}
			elsif params[:res_type] == Deal::TYPES[:stone]
				{:stone => params[:count].to_i}
			else
				{}
			end
		when Deal.types[:egg]
			{}
		else
			{}
		end

		if goods.empty?
			render_error(Error.types[:normal], "Invalid goods type") and return
		end

		if @player.spend!(goods)
			Deal.create :status => 1,
									:type => params[:type],
									:res_type => params[:res_type],
									:count => params[:count],
									:gid => params[:gid],
									:end_time => Time.now.to_i + 7.days
		end
		render_success(:player => @player.to_hash(:resources, :items))		
	end
end
