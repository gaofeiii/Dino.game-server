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
		:league_invite => 4
	}

	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :mail_type, Type::Integer
	attribute :sender_name			# sender nickname
	attribute :sender_id,			Type::Integer
	attribute :receiver_name		# receiver nickname
	attribute :receiver_id,		Type::Integer
	attribute :title
	attribute :content
	attribute :league_id
	attribute :is_read, 	Type::Boolean
	attribute :sys_mail_type, 	Type::Integer
	attribute :invitation_id

	index :mail_type
	index :sys_mail_type
	index :sender_name
	index :receiver_name
	index :league_id
	index :is_read

	def self.types
		TYPE
	end

	# args = {:receiver_name => "***"}
	def self.create_friend_invite_mail(args = {})
		return if args.blank?

		receiver = Player.find(:nickname => args[:receiver_name]).first
		return if receiver.nil?

		self.create :mail_type => TYPE[:system],
								:sys_mail_type => SYS_TYPE[:friend_invite],
								:sender_name => I18n.t('system', :locale => receiver.locale),
								:receiver_name => receiver.nickname,
								:title => I18n.t("mail.friend_invitation.title", :locale => receiver.locale),
								:content => I18n.t('mail.friend_invitation.content', :locale => receiver.locale, :friend_name => receiver.nickname)
	end

	# args = {:receiver_name => "***", :player_name => "***", :league_name => "***", :league_id => 1}
	def self.create_league_invite_mail(args = {})
		return if args.blank?

		receiver = Player.find(:nickname => args[:receiver_name]).first
		return if receiver.nil?

		self.create :mail_type => TYPE[:system],
								:sys_mail_type => SYS_TYPE[:league_invite],
								:sender_name => I18n.t('system', :locale => receiver.locale),
								:receiver_name => receiver.nickname,
								:league_id => args[:league_id],
								:title => I18n.t("mail.league_invitation.title", :locale => receiver.locale),
								:content => I18n.t('mail.league_invitation.content', :locale => receiver.locale, :player_name => args[:player_name], :league_name => args[:league_name])
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
end
