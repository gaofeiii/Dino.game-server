module PlayerMailHelper
	module ClassMethods
		
	end


	module BattleReportHelper

		def battle_report_key
			self.key[:battle_report]
		end

		def save_battle_report(troops_id, result)
			return false unless (troops_id && result.is_a?(::Hash))

			json_result = result.to_json
			time = result[:time].to_i

			mail = GameMail.create 	:mail_type 			=> GameMail::TYPE[:system],
															:sys_type 			=> GameMail::SYS_TYPE[:battle_report],
															:sender_id 			=> 0,
															:sender_name 		=> I18n.t('system', :locale => self.locale),
															:receiver_id		=> self.id,
															:receiver_name 	=> self.nickname,
															:title					=> I18n.t('mail.battle_report.title', :locale => self.locale),
															:content 				=> json_result

			# Clean battle mails, keeps 10 at most
			clean_battle_report(:count => 10)

			if mail
				db.hset battle_report_key, troops_id, mail.id
			end
		end

		def clean_battle_report(count:10)
			return false if count <= 0

			reports = db.hgetall battle_report_key

			if reports.size > count
				cleaned_ids = reports.keys - reports.keys.reverse[0, count - 1]
				cleaned_ids.each { |mail_id| GameMail[mail_id].try(:delete) }
				db.hdel battle_report_key, cleaned_ids
			end
		end

		def find_battle_report_by(troops_id:nil)
			return unless troops_id

			mail_id = db.hget battle_report_key, troops_id
			mail = GameMail[mail_id]

			db.hdel battle_report_key, troops_id unless mail

			mail
		end

	end
	
	module InstanceMethods
		include BattleReportHelper

		def has_new_mail?
			GameMail.find(:receiver_id => id, :is_read => false).any?
		end

		def game_mails(last_id:0, count:10)
			if last_id <= 0
				GameMail.find(:receiver_id => id).sort_by(:created_at, :order => 'DESC', :limit => [0, count])
			else
				GameMail.find(:receiver_id => id).ids.map do |mail_id|
					mail_id.to_i > last_id ? GameMail[mail_id] : nil
				end
			end.compact
		end

	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end