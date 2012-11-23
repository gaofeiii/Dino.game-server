class Player < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	include SessionsHelper
	include BeginningGuide

	# Player的属性
	attribute :account_id, 		Type::Integer
	attribute :nickname
	unique 		:nickname
	attribute :level, 				Type::Integer
	attribute :sun, 					Type::Integer
	attribute :gold_coin, 		Type::Integer
	attribute :experience, 		Type::Integer
	attribute :score, 				Type::Integer
	attribute :device_token
	
	attribute :village_id, 		Type::Integer
	attribute :session_id, 		Type::Integer
	attribute :country_id, 		Type::Integer

	attribute :league_member_ship_id


	collection :dinosaurs, 				Dinosaur
	collection :technologies, 		Technology
	collection :specialties, 			Specialty
	collection :items, 						Item
	collection :league_applys, 		LeagueApply
	collection :advise_relations, AdviseRelation
	collection :buffs, 						Buff
	collection :gods, 						God
	collection :troops,						Troops

	reference :league, League
	
	set :friends, 	Player
	
	

	
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
			:account_id => account_id,
			:score => score,
			:country_id => country_id.to_i
		}
		opts = if args.include?(:all)
			args | [:village, :techs, :dinosaurs, :advisors, :league]
		else
			args
		end

		opts.each do |att|
			case att
			when :village
				hash[:village] = village.to_hash(:all)
			when :techs
				hash[:techs] = technologies.to_a.map{|t| t.update_status!}.map{|t| t.to_hash}
			when :dinosaurs
				hash[:dinosaurs] = dinosaurs.map{|d| d.to_hash}
			when :items
				hash[:items] = items.map{|i| i.to_hash}
			when :specialties
				hash[:food] = specialties.map{|s| s.to_hash}
			when :league
				hash[:league] = league_info
			when :advisors
				hash[:advisors] = advise_relations.map do |ar|
					nk, lvl = Player.gets(ar.advisor_id, :nickname, :level)
					{:id => ar.advisor_id.to_i, :nickname => nk, :level => lvl}
				end
			when :beginning_guide
				has_beginning_guide = !beginning_guide_finished
				hash[:has_beginning_guide] = has_beginning_guide
				hash[:beginning_guide] = guide_info.current if has_beginning_guide
			end
		end
		return hash
	end

	def advisor_info
		{
			:id => id.to_i,
			:nickname => nickname,
			:level => level
		}
	end

	def league_info
		league.nil? ? {} : league.to_hash.merge(:level => league_member_ship_id)
	end

	def league_member_ship
		LeagueMemberShip[league_member_ship]
	end

	def foods
		specialties.to_a
	end

	def food_list
		specialties.map{|s| s.to_hash}
	end

	# 好友列表
	def friend_list
		friends.map do |friend|
			{
				:id => friend.id.to_i,
				:nickname => friend.nickname,
				:level => friend.level,
				:score => friend.score,
				:rank => rand(1..1000)
			}
		end
	end

	# 顾问
	def hire(advisor)
		advisors.add(advisor)
	end

	def fire(advisor)
		advisors.delete(advisor)
	end

	def mails(type)
		return [] if type <= 0
		result = case type
		when Mail::TYPE[:private]
			Mail.find(:receiver_name => nickname, :mail_type => type)
		when Mail::TYPE[:league]
			Mail.find(:league_id => league_id)
		else
			[]
		end
		return result		
	end

	def make_troops(*dinos)
		trp = Troops.create :player_id => id
		dinos.each do |dino|
			dino.update :troops_id => trp.id
		end
	end

	def send_push(message)
		send_push_message(:device_token => device_token, :message => message)
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

		# == Test ==
		Item.create :item_type => 1, :item_category => 1, :player_id => id
		1.upto(8) do |i|
			Specialty.create :type => i, :count => 999, :player_id => id
		end
	end

	def after_delete
		delete_village
	end

	private

	# 为新玩家创建村庄
	def create_village
		random_coord = Country.first.town_nodes_info.keys.sample
		x = random_coord / Country::COORD_TRANS_FACTOR
		y = random_coord % Country::COORD_TRANS_FACTOR
		vil = Village.create :name => "#{self.nickname}'s village", :player_id => self.id, 
		:x => x, :y => y, :country_index => 1
		self.set :village_id, vil.id
	end

	def delete_village
		vil = village
		vil.delete if vil
	end

end
