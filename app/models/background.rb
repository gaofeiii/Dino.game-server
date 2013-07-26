class Background
	@@queue = []
	@@cronjob = []
	@@redis = nil

	def self.redis(r)
		r
	end

	# Background.add_queue(Troops, 1, "refresh!", 1360045836)
	def self.add_queue(klass, id, action, time)
		key = "#{klass}:queue:#{action}"
		@@queue << key
		redis(r).multi do |t|
			t.sadd "Background:queues", key
			t.zadd key, time, id
		end
	end

	def self.all_queues(r)
		if @@queue.empty?
			@@queue = redis(r).smembers "Background:queues"
		end

		@@queue
	end

	def self.refresh_queues(r)
		self.all_queues(r).each do |queue_key|
			key_arr = queue_key.split(':')
			klass = key_arr.first.constantize
			action = key_arr.last

			raise "Invalid queue class:#{klass} @#{__FILE__}:#{__LINE__}" if klass.nil?

			ids = redis(r).zrangebyscore queue_key, "-inf", Time.now.to_i

			ids.each do |k_id|
				obj = klass[k_id]
				if obj.nil?
					redis(r).zrem queue_key, k_id
					next
				end

				obj.send(action)
				redis(r).zrem queue_key, k_id
			end
		end
	end

	def self.remove_queue(klass, id, action, r = Redis.new(GameServer.current.redis))
		key = "#{klass}:queue:#{action}"

		redis(r).multi do |t|
			t.srem "Background:queues", key
			t.zrem key, id
		end

		@@queue.delete(key)
	end

	## Cronjob defination.
	# 	- duration: 執行的間隔時間
	# 	- last_exec_time: 上次執行任務的時間
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
	def self.add_cronjob(klass, action, time_duration, r = Redis.new(GameServer.current.redis))
		key = "#{klass}:cronjob:#{action}"
		@@cronjob << key

		# begin_time = Time.now.beginning_of_hour.to_i
		begin_time = Time.now.to_i

		redis(r).multi do |t|
			t.sadd "Background:cronjobs", key
			t.hmset key, 'time_duration', time_duration, 'next_exec_time', begin_time + time_duration
		end
	end

	def self.all_cronjobs(r)
		if @@cronjob.empty?
			@@cronjob = redis(r).smembers("Background:cronjobs")
		end
		@@cronjob
	end

	def self.clear_all_cronjobs(r)
		jobs = all_cronjobs(r)

		redis(r).multi do |t|
			t.del *jobs if not jobs.empty?
			t.del "Background:cronjobs"
		end

		@@cronjob.clear
	end

	def self.refresh_cronjobs(r)
		self.all_cronjobs(r).map do |cron_key|
			cron = redis(r).hgetall cron_key # keys = [:time_duration, :last_exec_time]
			if cron.empty?
				redis(r).del cron_key
				next
			end

			now_time = ::Time.now.to_i

			# if cron['last_exec_time'].to_i + cron['time_duration'].to_i <= now_time
			next_exec_time = cron['next_exec_time'].to_i

			if now_time >= cron['next_exec_time'].to_i
				puts "--- Running #{cron_key} ..."
				key_arr = cron_key.split(':')
				klass = eval(key_arr.first)
				action = key_arr.last
				
				raise "Invalid cronjob class:#{klass} @#{__FILE__}:#{__LINE__}" if klass.nil?
				klass.send(action) 
				puts "--- Run '#{cron_key}' successfully! ---" if cron_key == 'redis:cronjob:bgsave'
				
				redis(r).hmset cron_key, 'next_exec_time', next_exec_time + cron['time_duration'].to_i
			end

		end
	end

	def self.perform!
		r = Redis.new(GameServer.current.redis)
		self.refresh_queues(r)
		self.refresh_cronjobs(r)
	end
end