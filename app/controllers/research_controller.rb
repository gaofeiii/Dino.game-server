class ResearchController < ApplicationController

	before_filter :validate_player

	def research
		tech = @player.technologies.find(:type => params[:tech_type].to_i).first

		if tech.nil?
			tech = Technology.create :type => params[:tech_type].to_i, :level => 0, :player_id => @player.id
		end
		tech.research!
		data = {:message_type => "OK", :player => @player.to_hash(:all)}
		render :json => data
	end
end
