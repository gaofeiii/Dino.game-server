class PrivateChat < ChatMessage

	attribute :listener_id
	attribute :listener_name

	index :player_id
	index :listener_id

	# Parameters
	# => args = {:player_id => 1, :last_id => 5, :count => 10}
	def self.messages(args = {})
		return [] if args[:player_id].to_i <= 0

		chats1 = []
		chats2 = []

		if args[:last_id].to_i <= 0
			chats1 = self.find(:player_id => args[:player_id]).sort_by(:created_at, :order => 'DESC', :limit => [0, args[:count]])
			chats2 = self.find(:listener_id => args[:player_id]).sort_by(:created_at, :order => 'DESC', :limit => [0, args[:count]])
		else
			c1 = self.find(:player_id => args[:player_id]).ids.select{|c_id| c_id.to_i > args[:last_id]}.map do |c_id|
				self[c_id]
			end
			c2 = self.find(:listener_id => args[:player_id]).ids.select{|c_id| c_id.to_i > args[:last_id]}.map do |c_id|
				self[c_id]
			end
			chats2 = c1 + c2
		end
		return chats1 + chats2
	end

	def to_hash
		{
			:id => id.to_i,
			:channel => channel,
			:content => content,
			:player_id => player_id.to_i,
			:time => created_at.to_i,
			:speaker => speaker,
			:listener_id => listener_id.to_i,
			:listener_name => listener_name
		}
	end

	protected
	def before_save
		super
		if channel == CHANNELS[:private] && listener_name.blank?
			self.listener_name = db.hget("Player:#{listener_id}", :nickname)
		end
	end
end
