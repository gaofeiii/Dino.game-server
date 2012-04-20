p 'Loading ohm.rb...' if Rails.env.development?

# Use hiredis for redis connecting
require 'redis/connection/hiredis'

# Should require 'ohm/contrib' for ohm extensions
require 'ohm/contrib'


# Set ohm redis server
Ohm.connect :ip => "127.0.0.1", :port => 6379

if Rails.env.production?
  Ohm.redis.select 11
elsif Rails.env.development?
  Ohm.redis.select 12
elsif Rails.env.test?
  Ohm.redis.select 13
end

class Numeric
  def object
    self
  end
end

module Ohm

  class Model
    # NOTE: 用更安全的方式重写Ohm::Model.lock!和unlock!方法
    # 原有的加锁机制存在明显的bug，详细请看：
    # http://huangz.iteye.com/blog/1381538

    # 以下是原始的lock!方法
    # def lock!
    #   until key[:_lock].setnx(Time.now.to_f + 0.5)
    #     next unless timestamp = key[:_lock].get
    #     sleep(0.1) and next unless lock_expired?(timestamp)

    #     break unless timestamp = key[:_lock].getset(Time.now.to_f + 0.5)
    #     break if lock_expired?(timestamp)
    #   end
    # end

    # 修改后的lock!方法
    # 只需要对key[:_lock]添加乐观锁来保证setnx期间key[:_lock]不会发生变化才会生效
    def lock_with_secure!
      # 修改后的lock!方法
      # 只需要对key[:_lock]添加乐观锁来保证setnx期间key[:_lock]不会发生变化才会生效
      # p "secure lock!"
      key[:_lock].watch
      until db.multi{|t| t.setnx(key[:_lock], Time.zone.now.to_f + 0.5)}
        next unless timestamp = key[:_lock].get
        sleep(0.1) and next unless lock_expired?(timestamp)

        break unless timestamp = key[:_lock].getset(Time.zone.now.to_f + 0.5)
        break if lock_expired?(timestamp)
      end

    end

    # 修改后的lock!方法
    # 增加unwatch方法
    def unlock_with_secure!
      db.unwatch
      unlock_without_secure!
    end

    alias_method_chain :lock!, :secure
    alias_method_chain :unlock!, :secure
  end


  module MyTimestamping
    def self.included(base)
      base.attribute :created_at, Integer
      base.attribute :updated_at, Integer
    end

    def create
      self.created_at ||= Time.now.utc.to_i

      super
    end

  protected
    def write
      self.updated_at = Time.now.utc.to_i

      super
    end
  end

end

class GameClass < Ohm::Model
  include Ohm::ActiveModelExtension
  include Ohm::Boundaries
  include Ohm::Typecast
  include Ohm::WebValidations
  include Ohm::NumberValidations
  include Ohm::Callbacks

  class << self

    def count
      db.scard("#{self.name}:all")
    end

    def current_id
      db.get("#{self.name}:id").to_i
    end
    # 定义self.find_by_attribute方法，返回查询结果的第一条记录，没有记录则返回nil
    # attribute必须在类中申明了index才可以使用此方法
    def method_missing(method, *args, &block)
      begin
        # p "Method's name: #{method}"
        # p "Args: #{args.first}"
        # p "Method's class :#{method.class}"
        # attri = method.slice(8, method.length)
        if method =~ /^find_by_/
          # p "Attribute: #{attri}"
          # p "args.first.class: #{args.first.class}"
          attri = method.to_s.gsub("find_by_", "")
          new_args = {attri.to_sym => args.first}
          # p "new_args: #{new_args}"
          # p "new_args' type: #{new_args.class}"
          self.find(new_args).first
        else
          raise NoMethodError
        end
      rescue
        raise NoMethodError
      end
    end
  end

  # NOTE: 对象的id要单独处理，否则会出错
  def to_hash
    new_hash = {:id => id.to_i}
    attributes.each do |key|
      value = send(key)
      begin
        new_hash[key] = value.object
      rescue
        new_hash[key] = value
      end
    end
    new_hash
  end

  def save!
    save
  end

  def reload
    x = self.class[id]
    attributes.each do |attribute|
      self.send("#{attribute}=", x.send(attribute))
    end
    self
  end

end


