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
  	uri = URI("https://sandbox.itunes.apple.com/verifyReceipt")
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
				self.player.receive!(:gems => gems)
			end
  	end
  end

  protected
  def before_create
  	self.is_valid = true
  end

end
