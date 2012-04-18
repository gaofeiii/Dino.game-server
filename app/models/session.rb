class Session < GameClass
  attribute :player_id, Integer
  attribute :session_key, String
  attribute :expired_time, Time

  index :player_id
  index	:session_key
  index	:expired_time

  after :create, :update_player

  def player
  	Player[player_id]
  end

  private
  def update_player
  	player.update :session_id => id
  end
end
