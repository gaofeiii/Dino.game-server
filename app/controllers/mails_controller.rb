class MailsController < ApplicationController

	before_filter :validate_player, :only => [:receive_mails, :check_new_mails]

	def send_mail

		sender = Player.with(:nickname, params[:sender])
		if sender.nil?
			render_error(Error.types[:normal], "Invalid sender name") and return
		end

		mail_type = params[:mail_type].to_i

		case mail_type
		# 个人邮件
		when Mail::TYPE[:private]
			receiver = Player.with(:nickname, params[:receiver])
			if receiver.nil?
				render_error(Error.types[:normal], "Invalid receiver name") and return
			end

			Mail.create :mail_type => Mail::TYPE[:private],
									:sender_name => sender.nickname, 
									:receiver_name => receiver.nickname,
									:title => params[:title],
									:content => params[:content]

			render :json => {:message => Error.success_message} and return
		# 公会邮件
		when Mail::TYPE[:league]
			league = League[params[:league_id]]

			if league.nil?
				render_error(Error.types[:normal], "Invalid league id") and return
			end

			Mail.create :mail_type => Mail::TYPE[:league],
									:sender_name => sender.nickname,
									:title => params[:title],
									:content => params[:content],
									:league_id => params[:league_id]

			render_success
		else
			render_error(Error.types[:normal], "Invalid mail type") and return
		end
	end

	def receive_mails
		# mail_type = params[:mail_type].to_i

		# if mail_type <= 0
		# 	render_error(Error.types[:normal], "Invalid mail type") and return
		# end

		# mails = @player.mails(mail_type).to_a
		mails = @player.all_mails
		render_success(:mails => mails, :has_new_mail => @player.has_new_mail)
	end

	def check_new_mails
		@player.troops.map(&:refresh!)
		mails = @player.all_mails(:last_id => params[:last_id], :last_report_time => params[:last_report_time])
		render_success(:mails => mails)
	end

	def read_mail
		@mail = Mail[params[:mail_id]]
		if @mail.nil?
			render_error(Error.types[:normal], "Mail not exist") and return
		end

		result = {
			:id => @mail.id,
			:mail_type => @mail.mail_type,
			:content => @mail.get_content
		}
		render_success(result)
	end

	def delete_mail
		@mail = Mail[params[:mail_id]]
		if @mail
			@mail.delete
		end
		render_success(:mail_id => params[:mail_id])
	end

	def mark_as_read
		params[:mail_ids].to_a.each do |m_id|
			Mail[m_id].update :is_read => true
		end
		render_success
	end
end
























