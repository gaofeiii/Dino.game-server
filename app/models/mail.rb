class Mail < Ohm::Model
	TYPE = {
		:system => 1,
		:private => 2,
		:league => 3
	}

	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :mail_type, Type::Integer
	attribute :sender_name			# sender nickname
	attribute :receiver_name		# receiver nickname
	attribute :title
	attribute :content
	attribute :league_id

	index :mail_type
	index :sender_name
	index :receiver_name
	index :league_id

	def to_hash
		{
			:sender => sender_name,
			:receiver => receiver_name,
			:title => title,
			:content => content,
			:time => created_at.to_i
		}
	end

	def sender
		@sender_player ||= Player.with(:nickname, sender_name)
	end

	def receiver
		@receiver_player ||= Player.with(:nickname, receiver_name)
	end

	def league
		@league ||= League[league_id]
	end
end
