class Session < GameClass
  attribute :player_id, Integer
  attribute :session_key, String
  attribute :expired_time, Time

  index :player_id
  index	:session_key
  index	:expired_time

  def player
  	Player[player_id]
  end

  private

end
