# Included by Player model.

module BattleReport
	module ClassMethods
		
	end
	
	module InstanceMethods
		def battle_report_key_with_time
			self.key[:battle_report_with_time]
		end

		def battle_report_with_troops_key
			self.key[:battle_report_with_troops]
		end

		def save_battle_report(troops_id, result)
			result_json = result.to_json
			tm = result[:time].to_i
			battle_mail = Mail.create :mail_type => Mail::TYPE[:system],
																:sys_mail_type => Mail::SYS_TYPE[:battle_report],
																:receiver_name => nickname, 
																:content => result_json,
																:title => I18n.t('mail.battle_report.title', :locale => locale),
																:sender_name => I18n.t('system', :locale => locale)
			db.multi do |t|
				t.zadd(battle_report_key_with_time, tm, battle_mail.id)
				t.hset(battle_report_with_troops_key, troops_id, battle_mail.id)
			end
		end

		# Get battle report in period: s_time to e_time.
		def get_battle_report_with_time(s_time = '-inf', e_time = '+inf')
			db.zrevrangebyscore(battle_report_key_with_time, e_time, s_time).map do |mail_id|
				mail = Mail[mail_id]
			end.compact
		end

		def get_battle_report_with_mail_id(last_mail_id = -1)
			db.zrevrange(battle_report_key_with_time, 0, last_mail_id).map do |mail_id|
				mail = Mail[mail_id]
			end.compact
		end

		# Return battle report: hash
		def get_battle_report_with_troops_id(troops_id = 0)
			battle_mail_id = db.hget(battle_report_with_troops_key, troops_id)
			mail = Mail[battle_mail_id]
			if mail
				return mail.get_content
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