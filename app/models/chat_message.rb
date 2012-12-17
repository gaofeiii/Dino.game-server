class ChatMessage < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	CHANNELS = {
		:world => 1,
		:league => 2,
		:private => 3
	}

	attribute :channel, 	Type::Integer
	attribute :speaker
	attribute :player_id
	attribute :content

	protected
	def before_save
		if speaker.blank?
			self.speaker = db.hget("Player:#{player_id}", :nickname)
		end
	end
end
