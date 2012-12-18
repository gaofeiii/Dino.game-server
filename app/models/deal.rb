class Deal < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	# 交易的状态
	STATUS = {
		:selling => 1,
		:closed => 2
	}

	# 可出售物品的类型
	TYPES = {
		:res => 1,
		:egg => 2
	}

	RES_TPYES = {
		:wood => 1,
		:stone => 2
	}

	attribute :status, 		Type::Integer		# Deal的状态，1表示出售者，2表示交易关闭
	attribute :type,	 		Type::Integer		# 表示出售物品的类型
	attribute :res_type,	Type::Integer		# 资源的类型
	attribute :gid, 			Type::Integer		# 非资源性物品的id
	attribute :count,			Type::Integer		# 资源物品的数量
	attribute :end_time,	Type::Integer		# 结束时间

	reference :seller, 	Player		# 卖家
	reference :buyer, 	Player		# 买家，如果正在出售中，则为空

	index :status
	index :type

	def self.types
		TYPES		
	end

	def to_hash
		@seller = seller
		hash = {
			:id => id.to_i,
			:type => type,
			:end_time => end_time,
			:seller_name => @seller.nickname,
			:seller_id => @seller.id,
			:count => count
		}
		case type
		when TYPES[:res]
			hash[:res_type] = res_type
		when TYPES[:egg]
			hash[:gid] = gid
		end
		return hash
	end

end
