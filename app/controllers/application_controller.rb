class ApplicationController < ActionController::Base
  # protect_from_forgery
  before_filter :set_ohm 
  before_filter :find_player unless Rails.env.test?




  private
  # NOTE: Redis database selecting ...
  # 不能全局地设置redis database，待解决中
  # 以下为临时解决方案
  def set_ohm
    case Rails.env
    when "production"
      Ohm.redis.select 11
    when "development"
      Ohm.redis.select 12
    when "test"
      Ohm.redis.select 13
    end
  end

  def find_player
  	# @current_player = Session.find_by_session_key(params[:session_key]).try(:player)
  	# unless @current_player
  	# 	render :json => "Login expired.", :status => 998 and return
  	# end
  end
end
