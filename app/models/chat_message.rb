class ChatMessage < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include OhmExtension

	attribute :channel, 	Type::Integer
	attribute :speaker
	attribute :content

	index :channel

	def self.world_messages(last_id = nil, number = 1)
		msgs = if last_id.nil?
			ChatMessage.all.sort_by(:created_at, :order => 'DESC', :limit => [0, number])
		else
			(last_id..(last_id.to_i + number - 1)).map do |i|
				ChatMessage[i]
			end.compact
		end.map(&:to_hash)
	end

	def to_hash
		{
			:id => id,
			:channel => channel,
			:speaker => speaker,
			:content => content,
			:time => created_at.to_i
		}
	end
end
