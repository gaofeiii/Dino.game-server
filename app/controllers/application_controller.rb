class ApplicationController < ActionController::Base
  before_filter :find_player unless Rails.env.test?

  private

  def find_player
  	# @current_player = Session.find_by_session_key(params[:session_key]).try(:player)
  	# unless @current_player
  	# 	render :json => "Login expired.", :status => 998 and return
  	# end
  end
end
