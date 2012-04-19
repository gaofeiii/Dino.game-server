class ApplicationController < ActionController::Base
  # protect_from_forgery
  before_filter :set_ohm if Rails.env.development?

  before_filter :find_player unless Rails.env.test?




  private
  # FIXME: [D] development模式的bug
  # ohm没有执行ohm.rb文件中Ohm.redis.select 12的语句
  # 以下为临时解决方案
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
