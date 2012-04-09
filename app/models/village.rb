class Village < GameClass
	attribute :name, 			String
	attribute :player_id, Integer

	index :name
	index :player_id

	def player
		Player[player_id]
	end
end
