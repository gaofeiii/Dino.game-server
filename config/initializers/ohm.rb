p 'Loading ohm.rb...' if Rails.env.development?

# Use hiredis for redis connecting
require 'redis/connection/hiredis'

# Should require 'ohm/contrib' for ohm extensions
require 'ohm/contrib'


# Set ohm redis server
# NOTE: test, development, production使用三个不同的redis-server,避免select的时效性
case Rails.env
when "production"
  Ohm.connect :ip => "127.0.0.1", :port => 6379
when "development"
  Ohm.connect :ip => "127.0.0.1", :port => 6379
when "test"
  Ohm.connect :ip => "127.0.0.1", :port => 6377
end

class Numeric
  def object
    self
  end
end

module Ohm


  module MyOhmExtensions
    module ClassMethods
      def count
        self.all.size
      end
    end
    
    module InstanceMethods
      
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end

  module DataTypes
    module MyType
      Integer   = lambda { |x| x.nil? ? x : x.to_i }
      Decimal   = lambda { |x| x.nil? ? x : BigDecimal(x.to_s) }
      Float     = lambda { |x| x.nil? ? x : x.to_f }
      Boolean   = lambda { |x| x.nil? ? x : !!x }
      Time      = lambda { |t| t && (t.kind_of?(::Time) ? t : ::Time.parse(t)) }
      Date      = lambda { |d| d.nil? ? d : d && (d.kind_of?(::Date) ? d : ::Date.parse(d)) }
      Timestamp = lambda { |t| t.nil? ? t : t && UnixTime.at(t.to_i) }
      Hash      = lambda { |h| h && (h.kind_of?(::Hash) ? SerializedHash[h] : JSON(h)) }
      Array     = lambda { |a| a && (a.kind_of?(::Array) ? SerializedArray.new(a) : JSON(a)) }
      Symbol    = lambda { |x| x.nil? ? x : x.to_sym}
    end
  end
  
end

class GameClass < Ohm::Model
  # including attribute types, callbacks, and default timestamps.
  # PS: Timestamps are unix time, which is a utc integer.
  include Ohm::DataTypes::MyType
  include Ohm::Callbacks
  include Ohm::Timestamps


  # The following class methods define some active record features
  # For example:
  # class User < Ohm::Model
  #   attribute :name
  # end
  #
  # u1 = User.create :name => "user1"
  # u2 = User.create :name => "user2"
  # u3 = User.create :name => "user3"
  # 
  # User.first == u1 # => true
  # User.last == u2  # => true
  # User.current_id # => 3
  # User.count # => 3

  class << self
    [:first, :blank?, :empty].each do |med|
      define_method(med) do
        all.send(med)
      end
    end

    # TODO: [D] Find a way to get the last instance.
    # The method below is incorrect when self[current_id] was deleted.
    #
    # def last
    #   self[current_id]
    # end

    def count
      all.size
    end

    def current_id
      db.get(key[:id]).to_i
    end
  end

  # Return a hash with all model's attributes except timestamps
  def to_hash
    attrs = {}
    attrs[:id] = id.to_i unless new?
    (attributes.keys - [:updated_at, :created_at]).each do |key, value|
      attrs[key] = send(key)
    end
    return attrs
  end
end


