class Player < GameClass

	# Player的属性
	attribute :account_id, 		Integer
	attribute :nickname, 			String
	attribute :level, 				Integer
	attribute :experience, 		Float
	attribute :village_id, 		Integer
	attribute :session_id, 		Integer

	include Ohm::MyTimestamping
	
	# 为Player添加索引便于查找
	index :account_id
	index :nickname
	index :level
	index :experience

	# Callbacks
	after :create, :create_village


	# 验证属性字段的方法
	# 注：validate方法优先于initialize方法
	def validate
		assert_numeric :level
		assert_numeric :experience
	end

	# 构造函数
	def initialize(args = {})
		super
		self.level = 1 if level.nil?
		self.experience = 0 unless experience
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
		(session && session.expired_time > Time.now.utc) ? true : false
	end

	# 获取玩家所有的信息，包括村庄的完整信息
	def full_info
		self.to_hash.merge(:village => village.try(:full_info))
	end

	# 为新玩家创建村庄
	def create_village
		vil = Village.create :name => "#{self.nickname}'s village", :player_id => self.id
		self.update :village_id => vil.id
	end
end
