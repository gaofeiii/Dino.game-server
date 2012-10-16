class MailsController < ApplicationController

	before_filter :validate_player, :only => :receive_mails

	def send_mail

		sender = Player.with(:nickname, params[:sender])
		if sender.nil?
			render :json => {:error => "Invalid sender name"} and return
		end

		mail_type = params[:mail_type].to_i

		case mail_type
		# 个人邮件
		when Mail::TYPE[:private]
			receiver = Player.with(:nickname, params[:receiver])
			if receiver.nil?
				render :json => {:error => "Invalid receiver name"} and return
			end

			Mail.create :mail_type => Mail::TYPE[:private],
									:sender_name => sender.nickname, 
									:receiver_name => receiver.nickname,
									:title => params[:title],
									:content => params[:content]

			render :json => {:message => "SUCCESS"} and return
		# 公会邮件
		when Mail::TYPE[:league]
			league = League[params[:league_id]]

			if league.nil?
				render :json => {:error => "Invalid league id"} and return
			end

			Mail.create :mail_type => Mail::TYPE[:league],
									:sender_name => sender.nickname,
									:title => params[:title],
									:content => params[:content],
									:league_id => params[:league_id]

			render :json => {:message => "SUCCESS"}
		else
			render :json => {:error => "Invalid mail type"} and return
		end
	end

	def receive_mails
		mail_type = params[:mail_type].to_i

		if mail_type <= 0
			render :json => {:error => "Invalid mail type"} and return
		end

		mails = @player.mails(mail_type).to_a
		render :json => {:mails => mails}
	end
end
























