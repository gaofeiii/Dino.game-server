class Player < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	# Player的属性
	attribute :account_id, 		Type::Integer
	attribute :nickname
	unique 		:nickname
	attribute :level, 				Type::Integer
	attribute :sun, 					Type::Integer
	attribute :gold_coin, 		Type::Integer
	attribute :experience, 		Type::Integer
	attribute :score, 				Type::Integer
	
	attribute :village_id, 		Type::Integer
	attribute :session_id, 		Type::Integer
	attribute :country_id, 		Type::Integer

	# relations
	collection :dinosaurs, 		:Dinosaur
	collection :technologies, :Technology
	collection :specialties, 	:Specialty
	
	# indices
	index :account_id
	index :nickname
	index :level
	index :experience
	index :country_id


	def village
		Village[village_id]
	end

	# 玩家登录后的session
	def session
		Session[session_id]
	end

	# 玩家是否在线？
	def logined?
		(session && session.expired_at > ::Time.now.utc) ? true : false
	end

	# player的spend!方法：
	# 参数为hash，key值是:wood, :stone, :population, :gold, :sun
	# 前三个为玩家所属村落的资源，后两者为玩家的基本货币单位
	# 返回值：某项资源不够返回false，成功返回玩家信息
	# 
	# E.g. player = Player.create :nickname => 'gaofei'
	# # 假设以下数值
	# player.gold_coin
	# => 100
	# player.sun
	# => 50
	# player.village.wood
	# => 200
	#
	# player.spend!(:gold_coin => 10, :sun => 5, :wood => 100)
	#
	def spend!(args = {})
		vil = (args.include?(:wood) or args.include?(:stone) or args.include?(:population)) ? village : nil
		db.multi do |t|
			args.each do |att, val|
				if att.in?([:gold_coin, :sun])
					return false if send(att) < val || val < 0
					t.hincrby(key, att, -val)
				elsif att.in?([:wood, :stone, :population])
					return false if vil.send(att) < val || val < 0
					t.hincrby(vil.key, att, -val)
				end
			end
		end
		load!
	end

	# player的receive!方法：
	# 参数与返回值同spend!方法
	def receive!(args = {})
		vil = (args.include?(:wood) or args.include?(:stone) or args.include?(:population)) ? village : nil
		db.multi do |t|
			args.each do |att, val|
				if att.in?([:gold_coin, :sun])
					t.hincrby(key, att, val)
				elsif att.in?([:wood, :stone, :population])
					t.hincrby(vil.key, att, val)
				end
			end
		end
		load!
	end

	# player的to_hash方法，主要用于render的返回值
	# 参数为symbol数组
	# 若参数为空返回基本信息
	# 带上参数则查询并返回参数所对应的信息，如player.to_hash(:village, :techs)
	# 只要包含:all参数，返回所有的信息
	def to_hash(*args)
		hash = {
			:id => id.to_s,
			:nickname => nickname,
			:level => level,
			:sun => sun,
			:gold_coin => gold_coin,
			:experience => experience,
			:account_id => account_id
		}
		opts = if args.include?(:all)
			args + [:village, :techs]
		else
			args
		end

		opts.each do |att|
			case att
			when :village
				hash[:village] = village.to_hash(:all)
			when :techs
				hash[:techs] = technologies.to_a.map(&:update_status!).map(&:to_hash)
			end
		end
		return hash
	end

	# Callbacks
	protected

	def before_create
		self.gold_coin = 99999
		self.sun = 9999
		self.level = 1 if (level.nil? or level == 0)
	end

	def after_create
		create_village
	end

	def after_delete
		delete_village
	end

	private

	# 为新玩家创建村庄
	def create_village
		vil = Village.create :name => "#{self.nickname}'s village", :player_id => self.id, 
		:x => rand(50), :y => rand(50), :country_id => default_country.id
		self.set :village_id, vil.id
	end

	def delete_village
		vil = village
		vil.delete if vil
	end

	def default_country
		case Rails.env
		when "test"
			Country.all.blank? ? Country.create(:name => :test_country, :serial_id => 11) : Country.first
		else
			Country.all.first
		end
	end

end
