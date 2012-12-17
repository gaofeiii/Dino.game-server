class LeagueChat < ChatMessage

	attribute :league_id

	index :league_id

	# Parameters:
	# => args = {:league_id => 1, :last_id => 123, :count => 10}
	def self.messages(args = {})
		if args[:league_id].nil? || !League.exists?(args[:league_id])
			return []
		end

		if args[:last_id].to_i <= 0
			self.find(:league_id => args[:league_id]).sort_by(:created_at, :order => 'DESC', :limit => [0, args[:count]])
		else
			self.find(:league_id => args[:league_id]).ids.select{|c_id| c_id.to_i > args[:last_id]}.map do |c_id|
				self[c_id]
			end
		end.compact.map{|c| c.to_hash}
	end

	def to_hash
		{
			:id => id.to_i,
			:channel => channel,
			:league_id => league_id.to_i,
			:content => content,
			:player_id => player_id.to_i,
			:time => created_at.to_i,
			:speaker => speaker
		}
	end
end
