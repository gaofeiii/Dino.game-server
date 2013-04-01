class WorldChat < ChatMessage

	index :player_id

	def self.messages(args = {})
		if args[:last_id].to_i <= 0
			self.all.sort_by(:created_at, :order => 'DESC', :limit => [0, args[:count]])
		else
			((args[:last_id] + 1)..(args[:last_id].to_i + count)).map do |c_id|
				self[c_id]
			end
		end.compact.map{|c| c.to_hash}
	end

	def self.create_system_message(msg, locale = :en)
		self.create :channel => 4, :speaker => I18n.t('system', :locale => locale), :content => Base64.encode64(msg)
	end

	def to_hash
		{
			:id => id.to_i,
			:channel => channel,
			:content => content,
			:player_id => player_id.to_i,
			:time => created_at.to_i,
			:speaker => speaker
		}
	end

end
