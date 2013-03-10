class MailsController < ApplicationController

	before_filter :validate_player, :only => [:receive_mails, :check_new_mails, :on_mail_ok]

	def send_mail

		# sender = Player.with(:nickname, params[:sender])
		sender = Player.find(:nickname => params[:sender]).first
		if sender.nil?
			render_error(Error::NORMAL, I18n.t('mails_error.receiver_not_exist')) and return
		end

		mail_type = params[:mail_type].to_i

		case mail_type
		# 个人邮件
		when Mail::TYPE[:private]
			# receiver = Player.with(:nickname, params[:receiver])
			receiver = Player.find(:nickname => params[:receiver]).first
			if receiver.nil?
				render_error(Error::NORMAL, I18n.t('mails_error.receiver_not_exist')) and return
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
				render_error(Error::NORMAL, "Invalid league id") and return
			end

			Mail.create :mail_type => Mail::TYPE[:league],
									:sender_name => sender.nickname,
									:title => params[:title],
									:content => params[:content],
									:league_id => params[:league_id]

			render_success
		else
			render_error(Error::NORMAL, "INVALID_MAIL_TYPE") and return
		end
	end

	def receive_mails
		# mail_type = params[:mail_type].to_i

		# if mail_type <= 0
		# 	render_error(Error::NORMAL, "Invalid mail type") and return
		# end

		# mails = @player.mails(mail_type).to_a
		mails = @player.all_mails
		render_success(:mails => mails, :has_new_mail => @player.has_new_mail)
	end

	def check_new_mails
		@player.troops.map(&:refresh!)
		mails = @player.all_mails(:last_id => params[:last_id], :last_report_time => params[:last_report_time])
		render_success 	:mails => mails, 
										:player => {
											:level => @player.level, 
											:experience => @player.experience, 
											:next_level_exp => @player.next_level_exp,
											:in_league => @player.in_league?,
											:wood => @player.wood,
											:stone => @player.stone,
											:gems => @player.gems,
											:gold_coin => @player.gold_coin
										}
	end

	def read_mail
		@mail = Mail[params[:mail_id]]
		if @mail.nil?
			render_error(Error::NORMAL, I18n.t('mails.mail_has_been_deleted')) and return
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
			m = Mail[m_id]
			m.update :is_read => true if m
		end
		render_success
	end

	def on_mail_ok
		mail = Mail.new(:id => params[:mail_id]).gets(:cached_data, :sys_mail_type)

		if mail.nil?
			render_error(Error::NORMAL, I18n.t('general.invitation_expired')) and return
		end

		case mail.sys_mail_type
		# 好友邀请
		when Mail::SYS_TYPE[:friend_invite]
			@friend = Player.new(:id => mail.cached_data[:player_id]).gets(:nickname)

			if @player.id == @friend.id
				render_error(Error::NORMAL, I18n.t('friends_error.cannot_add_self')) and return
			end

			if @player.friends.include?(@friend)
				render_error(Error::NORMAL, I18n.t('friends_error.already_add_friend', :friend_name => @friend.nickname)) and return
			end

			if @player.friends.add(@friend) && @friend.friends.add(@player)			
				render_success(I18n.t('general.add_friend_success'))
			else
				render_error(Error::NORMAL, I18n.t('friends_error.add_friend_failed'))
			end
			mail.delete
		# 公会邀请
		when Mail::SYS_TYPE[:league_invite]
			if not @player.league_id.blank?
				render_error(Error::NORMAL, I18n.t('league_error.already_in_a_league')) and return
			end

			league = League.new(:id => mail.cached_data[:league_id]).gets(:name)
			if league.nil?
				render_error(Error::NORMAL, I18n.t('league_error.league_not_found')) and return
			end

			if league.members.include?(@player)
				render_error(Error::NORMAL, I18n.t('league_error.already_in_this_league', :league_name => league.name)) and return
			end

			if league.add_new_member(@player)
				render_success(:player => @player.to_hash(:league), :result => I18n.t('general.join_league_success'))
			else
				render_error(Error::NORMAL, I18n.t('general.server_busy'))
			end
			mail.delete
		when Mail::SYS_TYPE[:league_apply]
			league = League[mail.cached_data[:league_id]]
			if league.nil?
				render_error(Error::NORMAL, I18n.t('league_error.league_not_found')) and return
			end

			member = Player[mail.cached_data[:player_id]]
			if member.nil?
				render_error(Error::NORMAL, I18n.t("league_error.member_does_not_exist")) and return
			end

			if member.league_id.to_i == league.id
				render_error(Error::NORMAL, I18n.t("league_error.member_already_join_in")) and return
			end

			unless member.league_id.blank?
				render_error(Error::NORMAL, I18n.t('league_error.member_already_in_a_league')) and return
			end

			if league.add_new_member(member)
				render_success(:player => @player.to_hash(:league), :result => I18n.t('league_error.accept_member_success'))
			else
				render_error(Error::NORMAL, I18n.t('general.server_busy'))
			end
			mail.delete
		else
			render_error(Error::NORMAL, I18n.t('general.server_busy'))
		end

	end
end
























