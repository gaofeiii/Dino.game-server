class Background
	@@queue = []

	# Background.add_queue(Troops, 1, "refresh!", 1360045836)
	def self.add_queue(klass, id, action, time)
		key = klass.key[:queue][action]
		@@queue << key
		Ohm.redis.multi do |t|
			t.sadd "Background:queues", key
			t.zadd key, time, id
		end
	end

	def self.all_queues
		if @@queue.empty?
			@@queue = Ohm.redis.smembers "Background:queues"
		end
		@@queue
	end

	def self.add_cronjob(klass, id, action, time)
		
	end

	def self.refresh_queues
		self.all_queues.each do |queue_key|
			key_arr = queue_key.split(':')
			klass = key_arr.first.constantize
			action = key_arr.last

			raise "Invalid queue class:#{klass} @#{__FILE__}:#{__LINE__}" if klass.nil?

			ids = Ohm.redis.zrangebyscore queue_key, "-inf", Time.now.to_i
			ids.each do |k_id|
				obj = klass[k_id]
				next if obj.nil?
				obj.send(action)
			end
		end
	end

	def self.perform!
		self.refresh_queues
	end
end