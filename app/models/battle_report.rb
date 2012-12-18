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

		def get_battle_report(s_time = 0, e_time = -1)
			db.zrevrange(battle_report_key, s_time, e_time, :with_scores => true).map do |result|
				re = JSON.parse(result[0]).merge('time' => result[1].to_i)
			end
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end