class Player < GameClass

	# Player的属性
	attribute :account_id, 		Integer
	attribute :nickname
	unique 		:nickname
	attribute :level, 				Integer
	attribute :sun, 					Integer
	attribute :gold_coin, 		Integer
	attribute :experience, 		Integer
	attribute :village_id, 		Integer
	attribute :session_id, 		Integer
	attribute :country_id, 		Integer

	collection :dinosaurs, 		:Dinosaur
	
	# 为Player添加索引便于查找
	index :account_id
	index :nickname
	index :level
	index :experience

	# 验证属性字段的方法
	# 注：validate方法优先于initialize方法
	def validate
		# assert_unique 	:nickname
		# assert_numeric 	:level
		# assert_numeric 	:experience
	end
	# 获取玩家的村庄
	def village
		Village[village_id]
	end

	# 设置玩家的村庄
	def village=(vil)
		self.village_id = vil ? vil.id : nil
		self
	end

	# 玩家登录后的session
	def session
		Session[session_id]
	end

	# 玩家是否在线？
	def logined?
		(session && session.expired_at > ::Time.now.utc) ? true : false
	end

	# Callbacks
	# protected

	def before_create
		init_attributes
	end

	def after_create
		create_village
	end

	# private

	def init_attributes
		self.level 			= 1 if level.nil?
		self.account_id = 0 if account_id.nil?
		self.sun 				= 0 if sun.nil?
		self.gold_coin 	= 0 if gold_coin.nil?
		self.experience = 0 if experience.nil?
		self.village_id = 0 if village_id.nil?
		self.session_id = 0 if session_id.nil?
	end

	# 为新玩家创建村庄
	def create_village
		vil = Village.create :name => "#{self.nickname}'s village", :player_id => self.id, 
		:x => rand(50), :y => rand(50), :country_id => default_country.id
		self.update :village_id => vil.id
	end

	def default_country
		case Rails.env
		when "test"
			Country.all.blank? ? Country.create(:name => :test_country, :serial_id => 11) : Country.first
		else
			Country.first
		end
	end

end
