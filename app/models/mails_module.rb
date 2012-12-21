module MailsModule
	module ClassMethods
		
	end
	
	module InstanceMethods
		def has_new_mail
			count = Mail.find(:receiver_name => nickname, :is_read => false).size
			return count > 0
		end

		def check_mails
			unread_sys_mails_count = Mail.find(:receiver_name => nickname, :mail_type => Mail.types[:system]).size
			unread_prv_mails_count = Mail.find(:receiver_name => nickname, :mail_type => Mail.types[:private]).size
			unread_lea_mails_count = Mail.find(:receiver_name => nickname, :mail_type => Mail.types[:league]).size
			new_mails_count = unread_sys_mails_count + unread_prv_mails_count + unread_lea_mails_count

			hash = {}
			hash[:has_new_mails] = new_mails_count > 0 ? true : false
			hash[:has_sys_mails] = unread_sys_mails_count > 0 ? true :false
			hash[:has_private_mails] = unread_prv_mails_count > 0 ? true :false
			hash[:has_league_mails] = unread_lea_mails_count > 0 ? true :false
			return hash
		end

		def private_mails(args = {})
			last_id = args[:last_id].to_i
			if last_id <= 0
				count = args[:count] ||= 10
				Mail.find(:mail_type => Mail::TYPE[:private], :receiver_name => nickname).sort_by(:created_at, :order => 'DESC', :limit => [0, count])
			else
				Mail.find(:mail_type => Mail::TYPE[:private], :receiver_name => nickname).ids.map do |m_id|
					Mail[m_id] if m_id.to_i > last_id
				end.compact
			end
		end

		def league_mails(args = {})
			return [] if league_id.blank?

			last_id = args[:last_id].to_i
			if last_id <= 0
				count = args[:count] ||= 10
				Mail.find(:mail_type => Mail::TYPE[:league], :league_id => league_id).sort_by(:created_at, :order => 'DESC', :limit => [0, count])
			else
				Mail.find(:mail_type => Mail::TYPE[:league], :league_id => league_id).ids.map do |m_id|
					Mail[m_id] if m_id.to_i > last_id
				end.compact
			end
		end

		def system_mails(args = {})
			last_id = args[:last_id].to_i
			if last_id <= 0
				count = args[:count] ||= 10
				Mail.find(:mail_type => Mail::TYPE[:system]).sort_by(:created_at, :order => 'DESC', :limit => [0, count])
			else
				Mail.find(:mail_type => Mail::TYPE[:system]).ids.map do |m_id|
					Mail[m_id] if m_id.to_i > last_id
				end.compact
			end
		end

		def battle_report_mails(args = {})
			get_battle_report_with_mail_id(args[:last_id])
		end

		def all_mails(args = {})
			last_id = args[:last_id].to_i
			private_mails(args) + league_mails(args) + system_mails(args) + get_battle_report_with_time("(#{args[:last_report_time]}")
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end