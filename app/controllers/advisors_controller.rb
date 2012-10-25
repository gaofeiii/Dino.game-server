class AdvisorsController < ApplicationController

	before_filter :validate_player, :only => [:hire, :fire, :apply]

	def advisor_list
		start = params[:page].to_i
		advs = Advisor.all.sort(:by => :level, :order => "DESC", :limit => [start, 50])
		render :json => {:advisors => advs}
	end

	def apply
		if Advisor.with(:player_id => @player.id)
			render :json => {:error => "YOU_HAVE_ALREADY_BEEN_AN_ADVISOR"} and return
		end

		Advisor.apply_advisor(@player, price)
		render :json => {:message => "success"}
	end

	def hire
		advisor = Advisor.with(:player_id => params[:player_id])

		if advisor.nil?
			render :json => {:error => "ADVISOR_NOT_FOUND"} and return
		end

		if advisor.hired?
			render :json => {:error => "ADVISOR_HAS_BEEN_HIRED"} and return
		end

		if @player.spend!(:gold_coin => advisor.price)
			advisor.mutex do
				advisor.player.receive!(:gold_coin => advisor.price((1-Advisor::Tax).to_i))
				AdviseRelation.create :advisor_id => advisor.player_id,
															:player_id => @player.id,
															:time => advisor.time,
															:type => params[:advisor_type]
				advisor.delete
			end
			render :json => {:player => @player.to_hash(:advisors)}
		else
			render :json => {:error => "NOT_ENOUGH_GOLD"}
		end
	end

	def fire
		advisor = Player[params[:advisor_id]]
		if advisor.nil?
			render :json => {:error => "ADVISOR_NOT_FOUND"} and return
		end

		if @player.include?(advisor)
			@player.advisors.delete(advisor)
			advisor.set :master_id, nil
		end
		render :json => {:player => @player.to_hash(:advisors)}
	end

	private

	def validate_advisor
		@advisor = Player[params[:advisor_id]]
		if @advisor.nil?
			render :json => {:error => "PLAYER_NOT_FOUND"} and return
		end
	end
end
