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
	attribute :to_player_id
	attribute :to_player_name

	index :channel

	def self.world_messages(last_id = nil, number = 1)
		msgs = if last_id.nil?
			ChatMessage.all.sort_by(:created_at, :order => 'DESC', :limit => [0, number])
		else
			((last_id + 1)..last_id.to_i + number).map do |i|
				ChatMessage[i]
			end.compact	
		end.map(&:to_hash)
	end

	def to_hash
		{
			:id => id.to_i,
			:channel => channel,
			:player_id => player_id.to_i,
			:speaker => speaker,
			:content => content,
			:time => created_at.to_i
		}
	end

	protected
	def before_save
		if speaker.blank?
			self.speaker = db.hget("Player:#{player_id}", :nickname)
		end

		if channel == CHANNELS[:private] && to_player_name.blank?
			self.to_player_name = db.hget("Player:#{to_player_id}", :nickname)
		end
	end
end
