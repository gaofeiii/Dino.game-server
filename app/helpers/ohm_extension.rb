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

		def gets(*atts)
			new_vals = db.hmget(key, atts)
			atts.each_with_index do |att, idx|
				self.send("#{att}=", new_vals[idx])
			end
			self
		end
		
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