class Background
	@@queue = []
	@@cronjob = []

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

	def self.refresh_queues
		self.all_queues.each do |queue_key|
			key_arr = queue_key.split(':')
			klass = key_arr.first.constantize
			action = key_arr.last

			raise "Invalid queue class:#{klass} @#{__FILE__}:#{__LINE__}" if klass.nil?

			ids = Ohm.redis.zrangebyscore queue_key, "-inf", Time.now.to_i

			ids.each do |k_id|
				obj = klass[k_id]
				if obj.nil?
					Ohm.redis.zrem queue_key, k_id
					next
				end

				obj.send(action)
				Ohm.redis.zrem queue_key, k_id
			end
		end
	end

	def self.remove_queue(klass, id, action)
		key = klass.key[:queue][:action]

		Ohm.redis.multi do |t|
			t.srem "Background:queues", key
			t.zrem key, id
		end

		@@queue.delete(key)
	end

	Cronjob = Struct.new(:duration, :last_exec_time) do
		def to_hash
			{
				:duration => duration,
				:last_exec_time => last_exec_time
			}
		end

		def to_map
			to_hash.to_a.flatten
		end
	end

	# 默认从当前时间的整点开始计时
	# 例如，当前时间为1:05，time_duration = 15.minutes，执行时间为1:15，1:30，1:45，以此类推
	def self.add_cronjob(klass, action, time_duration)
		key = klass.key[:cronjob][action]
		@@cronjob << key

		begin_time = Time.now.beginning_of_hour.to_i

		Ohm.redis.multi do |t|
			t.sadd "Background:cronjobs", key
			t.hmset key, 'time_duration', time_duration, 'next_exec_time', begin_time + time_duration
		end
	end

	def self.all_cronjobs
		if @@cronjob.empty?
			@@cronjob = Ohm.redis.smembers("Background:cronjobs")
		end
		@@cronjob
	end

	def self.clear_all_cronjobs
		jobs = all_cronjobs

		Ohm.redis.multi do |t|
			t.del *jobs if not jobs.empty?
			t.del "Background:cronjobs"
		end

		@@cronjob.clear
	end

	def self.refresh_cronjobs
		self.all_cronjobs.map do |cron_key|
			cron = Ohm.redis.hgetall cron_key # keys = [:time_duration, :last_exec_time]
			if cron.empty?
				Ohm.redis.del cron_key
				next
			end

			now_time = ::Time.now.to_i

			# if cron['last_exec_time'].to_i + cron['time_duration'].to_i <= now_time
			next_exec_time = cron['next_exec_time'].to_i

			if now_time >= cron['next_exec_time'].to_i
				key_arr = cron_key.split(':')
				klass = key_arr.first.constantize
				action = key_arr.last
				
				raise "Invalid cronjob class:#{klass} @#{__FILE__}:#{__LINE__}" if klass.nil?
				klass.send(action)
				Ohm.redis.hmset cron_key, 'next_exec_time', next_exec_time + cron['time_duration'].to_i
			end

		end
	end

	def self.perform!
		self.refresh_queues
		self.refresh_cronjobs
	end
end