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

		def sample
			self[Ohm.redis.srandmember(self.all.key)]
		end

		def delete_all
			self.all.each(&:delete)
		end

		def db
      $redis_count ||= 0
      $redis_count += 1
      Redis.current
    end

    def gets(id, *args)
    	db.hmget(key[id], args)
    end

    def mapped_gets(id, *args)
    	db.mapped_hmget(key[id], args)
    end

    def attribute(name, cast = nil)
    	@@attributes ||= Hash.new
    	@@attributes[self.name] ||= Array.new
    	@@attributes[self.name] << name
    	super
    end

    def all_attrs
    	@@attributes[self.name]
    end

	end
	
	module InstanceMethods
		
		def increase(key, count=1)
			db.hincrby(self.key, key, count)
			get(key)
		end

		def attributes
			super.merge!(:id => id)
		end

		def _skip_empty(atts)
      atts
    end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end