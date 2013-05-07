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

  def self.valid_orders
    self.all.select { |order| order.product_id =~ /com.dinosaur.gems/ }
  end

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
  	# result example:
    # result = {
    #   :receipt=> {
    #     :original_purchase_date_pst=>"2013-03-24 00:15:36 America/Los_Angeles", 
    #     :purchase_date_ms=>"1364109336550",
    #     :unique_identifier=>"22053267bb1848dc69310c3d3b7c123a917106ea", 
    #     :original_transaction_id=>"1000000068937410", 
    #     :bvrs=>"1.0.1", 
    #     :transaction_id=>"1000000068937410", 
    #     :quantity=>"1", 
    #     :unique_vendor_identifier=>"6B68A579-E9FF-4784-B045-1ED2E78385BD", 
    #     :item_id=>"612241660", 
    #     :product_id=>"com.dinosaur.gems.usd4999", 
    #     :purchase_date=>"2013-03-24 07:15:36 Etc/GMT", 
    #     :original_purchase_date=>"2013-03-24 07:15:36 Etc/GMT", 
    #     :purchase_date_pst=>"2013-03-24 00:15:36 America/Los_Angeles", 
    #     :bid=>"com.gaofei.dinostyle-international", 
    #     :original_purchase_date_ms=>"1364109336550"
    #   },
    #   :status=>0
    # }

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
