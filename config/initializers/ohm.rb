puts '--- Set Redis Connection Strategy ---' if Rails.env.development?

# Use hiredis for redis connecting
require 'redis/connection/hiredis'
require 'ohm/contrib'

Redis.current = case Rails.env
when "production"
  Redis.new ServerInfo.current.redis.merge(:port => 16379, :driver => :hiredis, :db => 0)
when "development"
  Redis.new ServerInfo.current.redis.merge(:driver => :hiredis, :db => 0)
when "test"
  Redis.new :host => "127.0.0.1", :port => 6377, :driver => :hiredis, :db => 0
end