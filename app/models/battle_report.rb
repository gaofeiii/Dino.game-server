module BattleReport
	module ClassMethods
		
	end
	
	module InstanceMethods
		def battle_report_key
			self.key[:battle_report]
		end

		def save_battle_report(time, result)
			result_json = result.is_a?(Hash) ? result.to_json : result
			db.zadd(battle_report_key, time, result_json)
		end

		# Get battle report in period: s_time to e_time.
		def get_battle_report(s_time = '-inf', e_time = '+inf')
			db.zrevrangebyscore(battle_report_key, e_time, s_time, :with_scores => true).map do |result|
				re = JSON.parse(result[0]).merge('time' => result[1].to_i)
			end
		end

		def delete_battle_report(max = '+inf', min = '-inf')
			db.zremrangebyscore(battle_report_key, min, max)
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end