puts '--- Loading ohm.rb... ---' if Rails.env.development?

# Use hiredis for redis connecting
require 'redis/connection/hiredis'

# Should require 'ohm/contrib' for ohm extensions
require 'ohm/contrib'

Redis.current = case Rails.env
when "production"
  Redis.new ServerInfo.current.redis.merge(:driver => :hiredis, :db => 0)
when "development"
  Redis.new ServerInfo.current.redis.merge(:driver => :hiredis, :db => 0)
when "test"
  Redis.new :host => "127.0.0.1", :port => 6377, :driver => :hiredis, :db => 0
end

$my_config = {:redis_access_log => false}

module Ohm

  def self.redis
   if Rails.env.development?
     $redis_count ||= 0
     $redis_count += 1
     puts "*--- Ohm.redis ---*" if $my_config[:redis_access_log]
   end
   Redis.current
  end

  class Model
    def self.db
     if Rails.env.development?
       $redis_count ||= 0
       $redis_count += 1
       puts "*--- Model.db ---*" if $my_config[:redis_access_log]
     end
     Redis.current
    end

    def id
      raise MissingID if not defined?(@id)
      @id.to_i
    end

    def hello
      puts "world"
    end
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


