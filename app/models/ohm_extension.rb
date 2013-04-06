module Ohm
	def self.redis
		if Rails.env.development?
			$redis_count ||= 0
			$redis_count += 1
		end
		Redis.current
  end

  class Model
    def self.db
			if Rails.env.development?
				$redis_count ||= 0
				$redis_count += 1
			end
     Redis.current
    end

    # Make id forced to integer
    def id
      raise MissingID if not defined?(@id)
      @id.to_i
    end

    def hello
      puts "world"
    end
  end

  # 覆盖Timestamps module，让时间戳都为整数格式
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

  # 添加hash和array新类型，使nil默认转为为对应类型的空类型
  module DataTypes
    module Type
      SmartHash = lambda do |h|
        if h
        	if h.is_a?(::Hash)
        		h.is_a?(SerializedHash) ? h : SerializedHash[h]
        	else
        		SerializedHash[JSON(h).deep_symbolize_keys]
        	end
        else
          SerializedHash.new
        end
      end

      SmartArray = lambda do |a|
        if a
        	if a.is_a?(::Array)
        		a.is_a?(SerializedArray) ? a : SerializedArray.new(a)
        	else
        		SerializedArray.new JSON(a)
        	end
        else
          SerializedArray.new
        end
      end

      SmartHashesArray = lambda do |a|
      	a.is_a?(SerializedArray) ? a : SmartArray[a].map! { |element| element.deep_symbolize_keys }
      end

    end
  end
end

module OhmExtension
	module ClassMethods
		def count
			self.all.size
		end

		def first
			self.all.first
		end

		def last
			self[self.all.ids.max]
		end

		def sample(n = 1)
			if n == 1
				self[db.srandmember(self.all.key)]
			elsif n > 1
				db.srandmembers(self.all.key, n).map do |p_id|
					self[p_id]
				end
			else
				nil
			end
		end

		def delete_all
			self.all.each(&:delete)
		end

		def delete_attrs(*atts)
			self.all.ids.each do |id|
				db.hdel(self.key[id], atts)
			end
		end

		def get(id, att)
			db.hget(key[id], att)
		end

    def gets(id, *args)
    	db.hmget(key[id], args)
    end

    def sets(id, args = {})
    	return if args.blank?
    	atts_ary = Array.new
    	args.map do |k, v|
    		if k.in?(all_attrs)
    			atts_ary += [k, v]
    		end
    	end
    	db.hmset self.key[id], atts_ary
    end

    def mapped_gets(id, *args)
    	db.mapped_hmget(key[id], args)
    end

    def all_attrs
    	@@attributes[self.name]
    end

    def attribute(name, cast = nil, ext = nil)
      @@attributes ||= Hash.new
      @@attributes[self.name] ||= Array.new
      @@attributes[self.name] << name

      define_method(:"#{name}=") do |value|
        @attributes[name] = value
      end

      if cast.nil?
        define_method(name) do
          @attributes[name]
        end
      elsif cast == Ohm::DataTypes::Type::SmartHash or cast == Ohm::DataTypes::Type::SmartArray or cast == Ohm::DataTypes::Type::SmartHashesArray
        define_method(name) do
          @attributes[name] = cast[@attributes[name]]
          @attributes[name].extend(ext) if ext
          @attributes[name]
        end
      else
        define_method(name) do
          cast[@attributes[name]]
        end
      end
    end # === End of 'def attribute(name, cast = nil)' ===

	end
	
	module InstanceMethods

		def gets(*atts)
			new_vals = db.hmget(key, atts)
			atts.each_with_index do |att, idx|
				self.send("#{att}=", new_vals[idx])
			end
			self
		end

		def sets(args = {})
			return false if args.blank?

			if (args.keys & self.class.all_attrs).size < args.size
				raise "Invalid attribute for #{self.class.name}"
			end

			if db.hmset(key, args.to_a.flatten) == "OK"
				args.each do |att, val|
					self.send("#{att}=", val)
				end
				return self
			else
				false
			end
		end
		
		def increase(key, count=1)
			db.hincrby(self.key, key, count)
			get(key)
		end

		def increase_by_float(att, num)
			db.hincrbyfloat(self.key, att, num)
			get(att)
		end

		def attributes
			super.merge!(:id => id)
		end

		def _skip_empty(atts)
			new_atts = {}
      atts.each do |att, val|
        new_atts[att] = val
      end

      new_atts
    	# {}.tap do |ret|
     #    atts.each do |att, val|
     #      unless val.to_s.empty?
     #        if val.is_a?(Ohm::DataTypes::SerializedHash) or val.is_a?(Ohm::DataTypes::SerializedArray)
     #          ret[att] = send(att).to_s
     #        else
     #          ret[att] = send(att)
     #        end
     #      end
          
     #    end

     #    throw :empty if ret.empty?
      # end
    end

    def exists?
    	if @id.nil?
    		return false
    	else
    		!self.class[@id].nil?
    	end
    end

    def deleted?
    	!exists?
    end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end