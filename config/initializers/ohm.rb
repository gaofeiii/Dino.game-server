p 'Loading ohm.rb...' if Rails.env.development?

# Use hiredis for redis connecting
require 'redis/connection/hiredis'

# Should require 'ohm/contrib' for ohm extensions
require 'ohm/contrib'

Redis.current = case Rails.env
when "production"
  Redis.new :host => "127.0.0.1", :port => 6379, :driver => :hiredis
when "development"
  Redis.new :host => "127.0.0.1", :port => 6379, :driver => :hiredis
when "test"
  Redis.new :host => "127.0.0.1", :port => 6377, :driver => :hiredis
end


module Ohm

  def self.redis
  	p "--- Redis.current ---"
    $redis_count ||= 0
    $redis_count += 1
    Redis.current
  end

  # 重写Timestamps module，让时间戳都为整数格式
  module Timestamps
  	def self.included(model)
  		model.attribute :created_at, DataTypes::Type::Integer
  		model.attribute :updated_at, DataTypes::Type::Integer
  	end

  	def save!
  		self.created_at = Time.now.utc.to_i if new?
  		self.updated_at = Time.now.utc.to_i

  		super
  	end
  end

end


