class Mail < Ohm::Model
	TYPE = {
		:system => 1,
		:private => 2,
		:league => 3
	}

	SYS_TYPE = {
		:normal => 1,
		:battle_report => 2,
		:friend_invite => 3,
		:league_invite => 4,
		:league_apply	 => 5
	}

	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :mail_type, 			Type::Integer
	attribute :sender_name			# sender nickname
	attribute :sender_id,				Type::Integer
	attribute :receiver_name		# receiver nickname
	attribute :receiver_id,			Type::Integer
	attribute :title
	attribute :content
	attribute :league_id
	attribute :is_read, 				Type::Boolean
	attribute :sys_mail_type, 	Type::Integer
	attribute :cached_data

	index :mail_type
	index :sys_mail_type
	index :sender_name
	index :receiver_name
	index :league_id
	index :is_read

	include MailHelper

	def cached_data
		cache = @attributes[:cached_data]
		if cache.is_a?(String)
			cache = JSON(cache).deep_symbolize_keys
		end
		cache
	end

	def self.types
		TYPE
	end

	# args = {
	# 	:receiver_id 		=> 1, 
	# 	:receiver_name 	=> "xxx", 
	# 	:player_id 			=> 2, 
	# 	:player_name		=> "xxxx", 
	# 	:locale 				=> 'en'
	# }
	def self.create_friend_invite_mail(args = {})
		return if args.blank?
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:friend_invite],
								:sender_name 		=> I18n.t('system', :locale => args[:locale]),
								:receiver_name 	=> args[:receiver_name],
								:title 					=> I18n.t("mail.friend_invitation.title", :locale => args[:locale]),
								:content 				=> I18n.t('mail.friend_invitation.content', :locale => args[:locale], :friend_name => args[:player_name]),
								:cached_data 		=> {:player_id => args[:player_id], :receiver_id => args[:receiver_id]}
	end

	# args = {
	# 	:receiver_id 		=> 1, 
	# 	:receiver_name 	=> "xxx", 
	# 	:player_id 			=> 2, 
	# 	:player_name		=> "xxxx",
	# 	:league_id			=> 1,
	# 	:league_name 		=> "xxxxx"
	# 	:locale 				=> 'en'
	# }
	# 创建公会邀请信
	def self.create_league_invite_mail(args = {})
		return if args.blank?
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:league_invite],
								:sender_name 		=> I18n.t('system', :locale => args[:locale]),
								:receiver_name 	=> args[:receiver_name],
								:title 					=> I18n.t("mail.league_invitation.title", :league_name => args[:league_name], :locale => args[:locale]),
								:content 				=> I18n.t('mail.league_invitation.content', :locale => args[:locale], :player_name => args[:player_name], :league_name => args[:league_name]),
								:cached_data 		=> {:player_id => args[:player_id], :receiver_id => args[:receiver_id], :league_id => args[:league_id]}
	end

	# args = {
	# 	:president 		=> 'xxx',
	# 	:player_id		=> 1,
	# 	:player_name 	=> 'xxx',
	# 	:league_id		=> 1
	# 	:league_name 	=> 'xxx',
	# 	:locale 			=> 'en'
	# }
	# 创建公会申请加入邮件
	def self.create_league_apply_mail(args = {})
		return if args.blank?
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:league_apply],
								:sender_name 		=> I18n.t('system', :locale => args[:locale]),
								:receiver_name 	=> args[:president],
								:title 					=> I18n.t("mail.league_application.title", :locale => args[:locale]),
								:content 				=> I18n.t('mail.league_application.content', :locale => args[:locale], :player_name => args[:player_name], :league_name => args[:league_name]),
								:cached_data 		=> {:player_id => args[:player_id], :receiver_id => args[:receiver_id], :league_id => args[:league_id]}
	end

	# 创建普通金矿收获邮件
	def self.create_goldmine_harvest_mail(args = {})
		locale = args[:locale] || :en
		mail = self.new :mail_type 			=> TYPE[:system],
										:sys_mail_type 	=> SYS_TYPE[:normal],
										:sender_name 		=> I18n.t('system', :locale => locale),
										:receiver_name 	=> args[:receiver_name],
										:receiver_id		=> args[:receiver_id],
										:title 					=> I18n.t('mail.goldmine_receive.title', :locale => locale),
										:content				=> I18n.t('mail.goldmine_receive.content', :locale => locale, :x => args[:x], :y => args[:y], :count => args[:count])
		mail.save
	end

	# args.include {:x => x, :y => y, :attacker => "attacker_name"}
	# 创建村落成功防守邮件
	def self.create_defense_village_win_mail(args = {})
		p "---creating defense village WIN mail---"
		locale = args[:locale] || :en
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:normal],
								:sender_name 		=> I18n.t('system', :locale => locale),
								:receiver_name 	=> args[:receiver_name],
								:receiver_id		=> args[:receiver_id],
								:title 					=> I18n.t('mail.defense_village_win_mail.title', :locale => locale),
								:content				=> I18n.t('mail.defense_village_win_mail.content', :locale => locale, :x => args[:x], :y => args[:y], :attacker => args[:attacker])
	end

	# args.include {:x => x, :y => y, :attacker => "attacker_name"}
	# 创建村落防守失败邮件
	def self.create_defense_village_lose_mail(args = {})
		p "---creating defense village LOSE mail---"
		locale = args[:locale] || :en
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:normal],
								:sender_name 		=> I18n.t('system', :locale => locale),
								:receiver_name 	=> args[:receiver_name],
								:receiver_id		=> args[:receiver_id],
								:title 					=> I18n.t('mail.defense_village_lose_mail.title', :locale => locale),
								:content				=> I18n.t('mail.defense_village_lose_mail.content', :locale => locale, :x => args[:x], :y => args[:y], :attacker => args[:attacker])
	end

	# args = {}
	# 创建荣誉战胜利邮件
	def self.create_match_win_mail(args = {})
		locale = args[:locale] || :en
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:normal],
								:sender_name 		=> I18n.t('system', :locale => locale),
								:receiver_name 	=> args[:receiver_name],
								:receiver_id		=> args[:receiver_id],
								:title 					=> I18n.t('mail.match_win_mail.title', :locale => locale),
								:content				=> I18n.t('mail.match_win_mail.content', :locale => locale, :attacker => args[:attacker], :score => args[:score])
	end

	# 创建荣誉战失败邮件
	def self.create_match_lose_mail(args = {})
		locale = args[:locale] || :en
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:normal],
								:sender_name 		=> I18n.t('system', :locale => locale),
								:receiver_name 	=> args[:receiver_name],
								:receiver_id		=> args[:receiver_id],
								:title 					=> I18n.t('mail.match_lose_mail.title', :locale => locale),
								:content				=> I18n.t('mail.match_lose_mail.content', :locale => locale, :attacker => args[:attacker], :score => args[:score])
	end

	# 创建防守金矿成功邮件
	def self.create_goldmine_defense_win_mail(args = {})
		locale = args[:locale] || :en
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:normal],
								:sender_name 		=> I18n.t('system', :locale => locale),
								:receiver_name 	=> args[:receiver_name],
								:receiver_id		=> args[:receiver_id],
								:title 					=> I18n.t('mail.goldmine_defense_win.title', :locale => locale),
								:content				=> I18n.t('mail.goldmine_defense_win.content', :locale => locale, :attacker => args[:attacker], :gx => args[:gx], :gy => args[:gy], :ax => args[:ax], :ay => args[:ay])
	end

	# 创建防守金矿失败邮件
	def self.create_goldmine_defense_lose_mail(args = {})
		locale = args[:locale] || :en
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:normal],
								:sender_name 		=> I18n.t('system', :locale => locale),
								:receiver_name 	=> args[:receiver_name],
								:receiver_id		=> args[:receiver_id],
								:title 					=> I18n.t('mail.goldmine_defense_lose.title', :locale => locale),
								:content				=> I18n.t('mail.goldmine_defense_lose.content', :locale => locale, :attacker => args[:attacker], :gx => args[:gx], :gy => args[:gy], :ax => args[:ax], :ay => args[:ay])
	end

	# args.keys.include?(:receiver_name, :receiver_id, :buyer, :gold, :goods_name, :count)
	# 创建交易成功邮件
	def self.create_deal_succses_mail(args = {})
		locale = args[:locale] || :en
		self.create :mail_type 			=> TYPE[:system],
								:sys_mail_type 	=> SYS_TYPE[:normal],
								:sender_name 		=> I18n.t('system', :locale => locale),
								:receiver_name 	=> args[:receiver_name],
								:receiver_id		=> args[:receiver_id],
								:title 					=> I18n.t('mail.deal_success.title', :locale => locale),
								:content				=> I18n.t('mail.deal_success.content', :locale => locale, :buyer => args[:buyer], :gold => args[:gold], :goods_name => args[:goods_name], :count => args[:count])
	end

	def to_hash(*args)
		hash = {
			:id => id.to_i,
			:sender => sender_name,
			:receiver => receiver_name,
			:title => title,
			:time => created_at.to_i,
			:is_read => is_read,
			:mail_type => mail_type,
			:sys_mail_type => sys_mail_type
		}
		hash
	end

	def get_content
		case sys_mail_type
		when SYS_TYPE[:battle_report]
			JSON.parse(content)
		else
			content
		end
	end

	def sender
		@sender_player ||= Player.find(:nickname => sender_name).first
	end

	def receiver
		@receiver_player ||= Player.find(:nickname => receiver_name).first
	end

	def league
		@league ||= League[league_id]
	end

	def invite_league
		@invite_league ||= League[cached_data[:league_id]]
	end

	def self.clean_up!
		curr_time = Time.now.beginning_of_day.to_i

		self.all.ids.each do |m_id|
			m = Mail.new(:id => m_id).gets(:created_at)

			if m.created_at < curr_time
				m.delete
			end
		end
	end

	protected
	def before_save
		if cached_data.is_a?(Hash)
			self.cached_data = cached_data.to_json
		end
	end
end
