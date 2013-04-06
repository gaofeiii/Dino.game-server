class GameMail < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension
	

	TYPE = {
		:system 	=> 1,
		:private 	=> 2,
		:league 	=> 3
	}

	SYS_TYPE = {
		:normal 				=> 1,
		:battle_report 	=> 2,
		:friend_invite 	=> 3,
		:league_invite 	=> 4,
		:league_apply		=> 5
	}

	attribute :mail_type, 		Type::Integer
	attribute :sys_type,			Type::Integer

	attribute :sender_id,			Type::Integer
	attribute :sender_name

	attribute :receiver_id,		Type::Integer
	attribute :receiver_name

	attribute :league_id,			Type::Integer

	attribute :title
	attribute :content # 如果是battle_report，content为JSON序列化的数据
	attribute :is_read,				Type::Boolean

	attribute :data, 					Type::SmartHash

	index :mail_type
	index :sys_type
	index :is_read
	index :sender_id
	index :receiver_id

	include GameMailHelper


	def to_hash
		hash = {
			:id 						=> id,
			:sender 				=> sender_name,
			:receiver 			=> receiver_name,
			:title 					=> title,
			:time 					=> created_at.to_i,
			:is_read 				=> is_read,
			:mail_type 			=> mail_type,
			:sys_mail_type 	=> sys_type
		}
		hash
	end

	def get_detail
		hash = {
			:id => id,
			:mail_type => mail_type
		}
		
		if sys_type == SYS_TYPE[:battle_report]
			p JSON(content)
			hash[:content] = JSON(content)
		else
			hash[:content] = content
		end

		hash
	end


	protected

	def before_create
		self.sender_name = Player.get(sender_id, :nickname) unless sender_name
		self.receiver_name = Player.get(receiver_id, :nickname) unless receiver_name
	end
end