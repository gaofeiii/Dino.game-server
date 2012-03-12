class Village < Ohm::Model
	attribute :name
	attribute :player_id

	index :name
	index :player_id

	def player
		Player[player_id]
	end
end
