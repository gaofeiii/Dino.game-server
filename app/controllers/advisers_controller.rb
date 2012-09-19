class AdvisersController < ApplicationController

	before_filter :validate_player, :only => [:hire, :fire, :apply]

	def adviser_list
		start = params[:page].to_i
		advs = Adviser.all.sort(:by => :level, :order => "DESC", :limit => [start, 50])
		render :json => {:advisers => advs}
	end

	def apply
		if Adviser.with(:player_id => @player.id)
			render :json => {:error => "YOU_HAVE_ALREADY_BEEN_AN_ADVISER"} and return
		end

		Adviser.apply_adviser(@player, price)
		render :json => {:message => "success"}
	end

	def hire
		adviser = Adviser.with(:player_id => params[:player_id])

		if adviser.nil?
			render :json => {:error => "ADVISER_NOT_FOUND"} and return
		end

		if adviser.hired?
			render :json => {:error => "ADVISE_HAS_BEEN_HIRED"} and return
		end

		if @player.spend!(:gold_coin => adviser.price)
			adviser.mutex do
				adviser.player.receive!(:gold_coin => adviser.price((1-Adviser::Tax).to_i))
				AdviseRelation.create :adviser_id => adviser.player_id,
															:player_id => @player.id,
															:time => adviser.time
															:type => params[:adviser_type]
				adviser.delete
			end
			render :json => {:player => @player.to_hash(:advisers)}
		else
			render :json => {:error => "NOT_ENOUGH_GOLD"}
		end
	end

	def fire
		adviser = Player[params[:adviser_id]]
		if adviser.nil?
			render :json => {:error => "ADVISER_NOT_FOUND"} and return
		end

		if @player.include?(adviser)
			@player.advisers.delete(adviser)
			adviser.set :master_id, nil
		end
		render :json => {:player => @player.to_hash(:advisers)}
	end

	private

	def validate_adviser
		@adviser = Player[params[:adviser_id]]
		if @adviser.nil?
			render :json => {:error => "PLAYER_NOT_FOUND"} and return
		end
	end
end
