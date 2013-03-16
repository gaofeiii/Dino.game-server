class ChatMessage < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	CHANNELS = {
		:world => 1,
		:league => 2,
		:private => 3,
		:system => 4
	}

	attribute :channel, 	Type::Integer
	attribute :speaker
	attribute :player_id
	attribute :content

	def self.clean_up!
		self.all.ids.each do |c_id|
			chat = self[c_id]
			if chat.created_at <= 1.day.ago.to_i
				chat.delete
			else
				break
			end
		end
	end

	protected
	def before_save
		if speaker.blank?
			self.speaker = db.hget("Player:#{player_id}", :nickname)
		end
		self.content = content.filter!
	end
end
