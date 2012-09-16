class Session < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks
  include OhmExtension

  attribute :player_id,   Type::Integer
  attribute :session_key
  unique    :session_key
  attribute :expired_at,  Type::Timestamp

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
