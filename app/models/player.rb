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
		self.level = 1 if (level.nil? or level == 0)
	end

	def after_create
		create_village
	end

	private

	# 为新玩家创建村庄
	def create_village
		vil = Village.create :name => "#{self.nickname}'s village", :player_id => self.id, 
		:x => rand(50), :y => rand(50), :country_id => default_country.id
		self.update :village_id => vil.id
	end

	def default_country
		# TODO: [D] In test mode, const will load just once, but redis db flushing is before/after each spec.
		# So the country and areamap info will be erased on every spec.
		# The method below is to make sure the test goes smoothly, but just temporary.
		case Rails.env
		when "test"
			Country.all.blank? ? Country.create(:name => :test_country, :serial_id => 11) : Country.first
		else
			Country.all.first
		end
	end

end
