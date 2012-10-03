class MailsController < ApplicationController

	def send_mail

		sender = Player.with(:nickname, params[:sender])
		if sender.nil?
			render :json => {:error => "Invalid sender name"} and return
		end

		case params[:mail_type]
		# 个人邮件
		when Mail::TYPE[:private]
			receiver = Player.with(:nickname, params[:receiver])
			if receiver.nil?
				render :json => {:error => "Invalid receiver name"} and return
			end

			Mail.create :type => Mail::TYPE[:private],
									:sender_name => sender.nickname, 
									:receiver_name => receiver.nickname,
									:title => params[:title],
									:content => params[:content]

			render :json => {:message => "Success"}
		# 公会邮件
		when Mail::TYPE[:league]
			league = League[params[:league_id]]
			
			if league.nil?
				render :json => {:error => "Invalid league id"} and return
			end

			Mail.create :type => Mail::TYPE[:league],
									:sender_name => sender.nickname,
									:title => params[:title],
									:content => params[:content],
									:league_id => params[:league_id]

			render :json => {:message => "Success"}
		else
			render :json => {:error => "Invalid mail type"} and return
		end
	end

	def receive_mails
		
	end
end
