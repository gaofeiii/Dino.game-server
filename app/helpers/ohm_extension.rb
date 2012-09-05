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
	end
	
	module InstanceMethods
		
		def increase(key, count=1)
			db.hincrby(self.key, key, count)
			get(key)
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end