class ApplicationController < ActionController::Base
  # protect_from_forgery
  before_filter :set_ohm if Rails.env.development?

  before_filter :find_player




  private
  def set_ohm
  	Ohm.redis.select 12
  end

  def find_player
  	@current_player = Session.find_by_session_key(params[:session_key]).try(:player)
  	unless @current_player
  		render :json => "Login expired.", :status => 998 and return
  	end
  end
end
