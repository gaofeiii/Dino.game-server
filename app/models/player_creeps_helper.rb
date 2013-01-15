module PlayerCreepsHelper
	module ClassMethods
		
	end
	
	module InstanceMethods

		def temp_creeps_key
			self.key[:temp_creeps]
		end
		
		def temp_creeps(creeps_id = nil)
			if creeps_id.nil?
				db.hgetall(temp_creeps_key).map { |c_id, cps| JSON(cps) }
			else
				creeps = db.hget(temp_creeps_key, creeps_id)
				creeps.nil? ? nil : JSON(creeps)
			end
		end

		# creeps = {}
		def save_creeps(creeps)
			return false if creeps.blank?

			creeps_id = creeps[:x] * Country::COORD_TRANS_FACTOR + creeps[:y]
			db.hset(temp_creeps_key, creeps_id, creeps.to_json)
		end

		def temp_creeps_idx
			db.hkeys(temp_creeps_key).map do |c_id|
				c_id.to_i
			end
		end

		def del_temp_creeps(creeps_idx)
			db.hdel(temp_creeps_key, creeps_idx)
		end

		def clear_all_temp_creeps
			db.del(temp_creeps_key)
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end