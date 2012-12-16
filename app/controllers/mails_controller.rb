class MailsController < ApplicationController

	before_filter :validate_player, :only => [:receive_mails]

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
		mail_type = params[:mail_type].to_i

		if mail_type <= 0
			render_error(Error.types[:normal], "Invalid mail type") and return
		end

		mails = @player.mails(mail_type).to_a
		render_success(:mails => mails)
	end

	def check_new_mails
		if not Player.exists?(params[:player_id])
			render_error(Error.types[:normal], "Invalid player id") and return
		end

		player = Player.new :id => params[:player_id]
		player.get(:nickname)
		
		render_success(:has_new_mail => player.has_new_mail)
	end

	def mark_as_read
		params[:mail_ids].to_a.each do |m_id|
			Ohm.redis.hset(Mail.key[m_id], :is_read, 1) if Mail.exists?(m_id)
		end
		render_success
	end
end
























