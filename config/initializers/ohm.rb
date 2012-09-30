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

end


