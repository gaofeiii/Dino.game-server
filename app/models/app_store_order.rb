class AppStoreOrder < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension
  
  attribute :base64_receipt
  attribute :purchase_date
  attribute :product_id
  attribute :is_validated, 		Type::Boolean
  attribute :transaction_id
  attribute :is_valid,				Type::Boolean
  attribute :unique_identifier

  index :is_validated
  index :transaction_id

  reference :player, 	Player

  def self.validate_iap(rcp)
  	uri = URI("https://buy.itunes.apple.com/verifyReceipt")
    uri = case ServerInfo.info[:env]
    when "production"
      URI("https://buy.itunes.apple.com/verifyReceipt")
    else
      URI("https://sandbox.itunes.apple.com/verifyReceipt")
    end
  	http = Net::HTTP.new(uri.host, uri.port)
  	http.use_ssl = true

  	request = Net::HTTP::Post.new(uri.request_uri)
  	request.content_type = 'application/json'
  	request.body = {'receipt-data' => rcp}.to_json

  	# res = http.start{ |h| h.request(request) }
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true){ |h| h.request(request) }

  	result = JSON.parse(res.body)

    result.deep_symbolize_keys
  end

  def validate!
  	return false if (is_validated || !is_valid)

  	result = self.class.validate_iap(base64_receipt)

  	if result[:status] == 0
 			self.product_id = result[:receipt][:product_id]
 			self.is_validated = true
			if self.save
				gems = Shopping.find_gems_count_by_product_id(self.product_id)
				if gems
          self.player.receive!(:gems => gems)
        else
          self.set :is_valid, 0
        end
			end
    else
      self.update :is_valid => false, :is_validated => false
  	end
  end

  protected
  def before_create
  	self.is_valid = true
  end

end
