class Session < GameClass
  attribute :player_id, Integer
  attribute :session_key
  unique    :session_key
  attribute :expired_at, Timestamp

  index :player_id
  index	:session_key
  index	:expired_at

  def player
  	Player[player_id]
  end

  protected

  def before_save
    self.expired_at = self.expired_at.to_i
  end
  private

end
