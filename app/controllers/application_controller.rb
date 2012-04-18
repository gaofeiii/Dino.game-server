class ApplicationController < ActionController::Base
  # protect_from_forgery
  before_filter :set_ohm if Rails.env.development?

  def set_ohm
  	Ohm.redis.select 12
  end
end
