module SortedSetModule
	
	module ClassMethods
		@@sorted_sets = Hash.new
		def sorted_set(att)
			@@sorted_sets[self.name] ||= []
			@@sorted_sets[self.name] << att
		end

		def sorted_all_ids(att = nil)
			return [] if att.nil?
			db.zrevrange(self.sorted_set_key(att), 0, -1)
		end

		def sorted_set_key(att)
			self.key[:sorted_set][att]
		end

		def sorted_set_attrs
			@@sorted_sets[self.name]
		end
	end
	
	module InstanceMethods
		def save!
			super
			if not new?
				self.class.sorted_set_attrs.each do |s_att|
					db.zadd(self.class.sorted_set_key(s_att), send(s_att), id)
				end
			end
			return self
		end

		def delete
			super
			self.class.sorted_set_attrs.each do |s_att|
				db.zrem(self.class.sorted_set_key(s_att), id)
			end
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end