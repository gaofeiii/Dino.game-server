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
      p "--- Redis.current ---"
      Redis.current
    end

    def gets(id, *args)
    	db.hmget(key[id], args)
    end

    def mapped_gets(id, *args)
    	db.mapped_hmget(key[id], args)
    end
	end
	
	module InstanceMethods
		
		def increase(key, count=1)
			db.hincrby(self.key, key, count)
			get(key)
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