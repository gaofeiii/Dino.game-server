module StatGameInfo
	CONSUME_GEMS_TYPE = %w(
		build_speed_up
		tech_speed_up
		hatch_speed_up
		dinosaur_heal
		buy_arena
		buy_egg
		buy_food
		buy_resource
		buy_vip
		buy_lottery
		buy_scroll
		buy_protection
		buy_dionsaur_space
	)

	CONSUME_GOLD_TYPE = %w(
		buy_egg
		egg_evolution
		train_dinosaur
		research
	)

	module ClassMethods
		
		def key
			"GameStatistics"
		end

		# Note: Gems stat related
		def record_gems_consume(type: nil, times: 0, count: 0)
			type_str = type.to_s
			p "type: #{type}"

			return false if type_str.blank? || count <= 0 || times <= 0 || !type_str.in?(CONSUME_GEMS_TYPE)

			p "recording..."

			Ohm.redis.multi do |t|
				t.hincrby "#{key}:gems:#{type}", :times, times
				t.hincrby "#{key}:gems:#{type}", :total_count, count
			end
		end

		def gems_consume_info
			result = {}

			CONSUME_GEMS_TYPE.each do |type|
				result[type.to_sym] = Ohm.redis.hgetall "#{key}:gems:#{type}"
			end

			result.deep_symbolize_keys
		end

		# Note: Gold stat related
		def record_gold_consume(type: nil, times: 0, count: 0)
			type_str = type.to_s

			return false if type_str.blank? || count <= 0 || times <= 0 || !type_str.in?(CONSUME_GOLD_TYPE)

			Ohm.redis.multi do |t|
				t.hincrby "#{key}:gold:#{type}", :times, times
				t.hincrby "#{key}:gold:#{type}", :total_count, count
			end
		end

		def gold_consume_info
			result = {}

			CONSUME_GOLD_TYPE.each do |type|
				result[type.to_sym] = Ohm.redis.hgetall "#{key}:gold:#{type}"
			end

			result.deep_symbolize_keys
		end

		def clear_gems_record!
			
		end

		def clear_gems_record!
			
		end

		def clear_all_record!
			clear_gems_record!
			clear_gems_record!
		end

	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end