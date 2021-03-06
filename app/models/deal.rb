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

	ORIGIN_TAX = 0.1

	# 可出售物品的类型
	CATEGORIES = {
		:res 	=> 1,
		:egg 	=> 2,
		:food => 3
	}

	RES_TYPES = {
		:wood => 1,
		1 => :wood,
		:stone => 2,
		2 => :stone
	}

	EGG_NAME = {
		1 => "scud", 
		2 => "king", 
		3 => "thorn", 
		4 => "hammer", 
		5 => "ripper", 
		6 => "headache", 
		7 => "raptor", 
		8 => "earthquake", 
		9 => "tyrant"
	}

	FOOD_NAME = {
		1 => 'pitaya', 
		2 => 'corn', 
		3 => 'watermelon', 
		4 => 'pineapple', 
		5 => 'fish', 
		6 => 'tiger', 
		7 => 'mammuthus', 
		8 => 'brachiosaurus'
	} 

	attribute :status, 		Type::Integer		# Deal的状态，1表示出售者，2表示交易关闭
	attribute :category,	Type::Integer 	# 交易物品的种类
	attribute :type,	 		Type::Integer		# 物品的类型
	attribute :quality,		Type::Integer		# 恐龙蛋的品质
	attribute :gid, 			Type::Integer		# 非资源性物品的id
	attribute :count,			Type::Integer		# 资源物品的数量
	attribute :end_time,	Type::Integer		# 结束时间
	attribute :price, 		Type::Float

	reference :seller, 	Player		# 卖家
	reference :buyer, 	Player		# 买家，如果正在出售中，则为空

	index :category
	index :status
	index :type
	index :end_time

	def self.types
		CATEGORIES		
	end

	def self.clean_up!
		self.all.map do |deal|
			if deal && deal.expired?
				deal.cancel!
			end
		end
	end

	def to_hash
		@seller = seller
		left_time = end_time - ::Time.now.to_i
		hash = {
			:id => id.to_i,
			:cat => category,
			:type => type,
			:end_time => left_time,
			:seller_name => @seller.nickname,
			:seller_id => @seller.id,
			:count => count,
			:price => price,
			:quality => quality
		}
		case category
		when CATEGORIES[:egg]
			hash[:gid] = gid
		end
		return hash
	end

	def cancel!
		self.mutex do

			if status == STATUS[:closed]
				return nil
			end

			case category
			when CATEGORIES[:res]
				res_name = RES_TYPES[type]
				if seller.receive!(res_name => count)
					self.delete
				end
			when CATEGORIES[:egg]
				itm = Item[gid]
				if itm
					itm.update :player_id => seller_id
					self.delete
				end
			when CATEGORIES[:food]
				seller.receive_food!(type, count)
				self.delete
			end
		end
	end

	# CATEGORIES = {
	# 	:res 	=> 1,
	# 	:egg 	=> 2,
	# 	:food => 3
	# }

	# RES_TYPES = {
	# 	:wood => 1,
	# 	1 => :wood,
	# 	:stone => 2,
	# 	2 => :stone
	# }
	def goods_name(locale = :en)
		case category
		when CATEGORIES[:res]
			if type == 1
				I18n.t('resource.wood', :locale => locale)
			elsif type == 2
				I18n.t('resource.stone', :locale => locale)
			end
		when CATEGORIES[:egg]
			I18n.t("egg_name.#{EGG_NAME[type]}", :locale => locale)
		when CATEGORIES[:food]
			I18n.t("food_name.#{FOOD_NAME[type]}", :locale => locale)
		end
	end

	def expired?
		::Time.now.to_i >= end_time
	end

	def refresh!
		if expired?
			cancel!
		end
	end

	protected

	def after_create
		Background.add_queue(self.class, self.id, "cancel!", self.end_time)
	end

end
