class Village < GameClass
	attribute :name, 			String
	attribute :x, 				Integer
	attribute :y, 				Integer

	attribute :player_id, Integer

	index :name
	index :player_id

	def player
		Player[player_id]
	end

	def as_json
		
	end
end
