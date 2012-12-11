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
	attribute :league_id,	Type::Integer
	attribute :speaker
	attribute :player_id
	attribute :content
	attribute :to_player_id
	attribute :to_player_name

	index :channel
	index :league_id
	index :player_id
	index :to_player_id

	def self.world_messages(last_id = nil, number = 1)
		msgs = if last_id.nil?
			ChatMessage.find(:channel => CHANNELS[:world]).sort_by(:created_at, :order => 'DESC', :limit => [0, number])
		else
			((last_id + 1)..last_id.to_i + number).map do |i|
				ChatMessage[i]
			end.compact	
		end.map(&:to_hash)
	end

	def self.league_messages(league_id, last_id = nil, count = 1)
		ChatMessage.find(:league_id => league_id).sort_by(:created_at, :order => 'DESC', :limit => [0, count]).map do |chat|
			chat.to_hash
		end
	end

	def self.private_messages(player_id, to_player_id, last_id = nil, count = 1)
		c1 = ChatMessage.find(:channel => CHANNELS[:private], :player_id => player_id, :to_player_id => to_player_id).sort_by(:created_at, :order => 'DESC', :limit => [0, count]).map do |chat|
			chat.to_hash
		end
		c2 = ChatMessage.find(:channel => CHANNELS[:private], :player_id => to_player_id, :to_player_id => player_id).sort_by(:created_at, :order => 'DESC', :limit => [0, count]).map do |chat|
			chat.to_hash
		end
		c1 + c2
	end

	def to_hash
		hash = {
			:id => id.to_i,
			:channel => channel,
			:content => content,
			:player_id => player_id.to_i,
			:time => created_at.to_i,
			:speaker => speaker
		}
		case channel
		when CHANNELS[:world]
			hash[:speaker] = speaker
		when CHANNELS[:league]
			hash[:league_id] = league_id
		when CHANNELS[:private]
			hash[:to_player_id] = to_player_id
			hash[:to_player_name] = to_player_name
		end
		return hash
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
