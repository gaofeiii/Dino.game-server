class Player < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	include SessionsHelper
	include BeginningGuide
	include MailsModule
	include BattleReport

	include RankModel

	include DailyQuest

	TYPE = {
		:normal => 0,
		:vip => 1,
		:npc => 2
	}

	# Player的属性
	attribute :account_id, 		Type::Integer
	attribute :nickname
	unique 		:nickname
	attribute :level, 				Type::Integer
	attribute :sun, 					Type::Integer
	attribute :gem,						Type::Integer
	attribute :gold_coin, 		Type::Integer
	attribute :experience, 		Type::Integer
	attribute :score, 				Type::Integer
	attribute :device_token
	attribute :avatar_id, 		Type::Integer		# 玩家头像的id
	attribute :is_advisor,		Type::Boolean
	attribute :is_hired,			Type::Boolean
	attribute :advisor_type,	Type::Integer
	attribute :battle_power,	Type::Integer

	attribute :player_type, 	Type::Integer
	
	attribute :village_id, 		Type::Integer
	attribute :session_id, 		Type::Integer
	attribute :country_id, 		Type::Integer

	attribute :locale

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
	collection :deals,						Deal, 	:seller
	collection :gold_mines,				GoldMine
	collection :strategies, 			Strategy

	reference :league, League
	
	set :friends, 	Player
	
	# indices
	index :account_id
	# index :nickname
	index :level
	index :experience
	index :country_id

	def is_npc?
		player_type == TYPE[:npc]
	end

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
		# vil = (args.include?(:wood) or args.include?(:stone) or args.include?(:population)) ? village : nil
		vil = Village.new :id => village_id
		vil.gets(:wood, :stone)

		db.multi do |t|
			args.symbolize_keys.each do |att, val|
				if att.in?([:gold_coin, :sun])
					return false if send(att) < val || val < 0
					t.hincrby(key, att, -val)
				elsif att.in?([:wood, :stone]) && vil
					return false if vil.send(att) < val || val < 0
					t.hincrby(vil.key, att, -val)
				end
			end
		end

		gets(:gold_coin, :sun)
	end

	# player的receive!方法：
	# 参数与返回值同spend!方法
	def receive!(args = {})
		vil = Village.new(:id => village_id)
		vil.gets(:wood, :stone)
		
		db.multi do |t|
			args.symbolize_keys.each do |att, val|
				if att.in?([:gold_coin, :sun])
					return false if val < 0
					t.hincrby(key, att, val)
				elsif att.in?([:wood, :stone])
					return false if val < 0
					t.hincrby(vil.key, att, val)
				end
			end
		end
		gets(:gold_coin, :sun)
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
			:country_id => country_id.to_i,
			:avatar_id => avatar_id,
			:player_power => battle_power
		}
		opts = if args.include?(:all)
			args | [:god, :troops, :specialties, :village, :techs, :dinosaurs, :advisors, :league, :beginning_guide, :queue_info]
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
				hash[:dinosaurs] = dinosaurs_info
			when :items
				hash[:items] = items.map{|i| i.to_hash}
			when :specialties
				hash[:food] = specialties.map{|s| s.to_hash}
			when :league
				hash[:league] = league_info
			when :advisors
				hash[:advisors] = AdviseRelation.find(:employer_id => id).map do |ar|
					ar.to_hash
				end
			when :beginning_guide
				has_beginning_guide = !beginning_guide_finished
				hash[:has_beginning_guide] = has_beginning_guide
				hash[:beginning_guide] = guide_info.current if has_beginning_guide
			when :queue_info
				hash[:max_queue_size] = action_queue_size
				hash[:queue_in_use] = curr_action_queue_size
			when :buff_info
				hash[:buffs] = buffs.to_a
			when :new_mails
				hash[:mail_status] = check_mails
			when :troops
				hash[:troops] = troops
			when :resources
				hash[:village] ||= {}
				hash[:village].merge!(:resources => village.resources)
			when :god
				if not gods.blank?
					hash[:god] = gods.first.to_hash
				end
			when :daily_quest
				reset_daily_quest!
				hash[:daily_quests] = daily_quests_full_info
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

	def my_advisors_info
		AdviseRelation.find(:employer_id => id).map do |ar|
			ar.to_hash
		end
	end

	def league_info
		league.nil? ? {} : league.to_hash.merge(:level => league_member_ship_id)
	end

	def dinosaurs_info
		# dinosaurs.find(:status => Dinosaur::STATUS[:infancy]).map(&:to_hash) + 
		# 	dinosaurs.find(:status => Dinosaur::STATUS[:adult]).map(&:to_hash)
		dinosaurs.map do |dino|
			dino.update_status!
			dino.to_hash
		end
	end

	def league_member_ship
		LeagueMemberShip[league_member_ship]
	end

	def foods
		specialties
	end

	def food_list
		specialties.map{|s| s.to_hash}
	end

	# 好友列表
	def friend_list
		friends.map do |friend|
			village_coords = Village.gets(friend.village_id, :x, :y)
			{
				:id => friend.id.to_i,
				:nickname => friend.nickname,
				:level => friend.level,
				:score => friend.score,
				:rank => rand(1..1000),
				:x => village_coords[0].to_i,
				:y => village_coords[1].to_i
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

	def make_troops(*dinos)
		trp = Troops.create :player_id => id
		dinos.each do |dino|
			dino.update :troops_id => trp.id
		end
	end

	def send_push(message)
		send_push_message(:device_token => device_token, :message => message)
	end

	# The queue has already been used.
	def curr_action_queue_size
		vil = village
		bd_queue_size = vil.buildings.find(:status => Building::STATUS[:new]).size + vil.buildings.find(:status => Building::STATUS[:half]).size
		tech_queue_size = 0#technologies.find(:status => Technology::STATUS[:researching]).size
		bd_queue_size + tech_queue_size
	end

	# The size of building or researching queue.
	def action_queue_size
		#db.sinterstore("Building:indices:village_id:#{village_id}", "Building:indices:type:#{Building.hashes[:residential]}").to_i
		village.buildings.find(:type => Building.hashes[:residential], :status => Building::STATUS[:finished]).size
	end

	def curr_research_queue_size
		technologies.find(:status => Technology::STATUS[:researching]).size
	end

	def total_research_queue_size
		village.buildings.find(:type => Building.hashes[:workshop]).size
	end

	def update_resource!
		self.village.refresh_resource!
	end

	def validate_iap(rcp)
  	uri = URI("https://sandbox.itunes.apple.com/verifyReceipt")
  	http = Net::HTTP.new(uri.host, uri.port)
  	http.use_ssl = true

  	request = Net::HTTP::Post.new(uri.request_uri)
  	request.content_type = 'application/json'
  	request.body = {'receipt-data' => rcp}.to_json

  	res = http.start{ |h| h.request(request) }
  	result = JSON.parse(res.body)

    # if result['status'] == 0
      # self.is_verified = true
    # end
    result
  end

  def locale
  	if @locale.blank?
  		@locale = 'cn'
  	end
  	@locale
  end

  def my_selling_list
  	deals
  end

  def find_food_by_type(type)
  	foods.find(:type => type).first
  end

	# Callbacks
	protected

	def before_create
		self.gold_coin = 1000
		self.sun = 100
		self.level = 1 if (level.nil? or level == 0)
		self.avatar_id = 1 if avatar_id.zero?
		self.country_id = Country.first.id
	end

	def after_create
		create_village

		# TODO: == Just for Test ==
		1.upto(8) do |i|
			Item.create :item_type => i, :item_category => 1, :player_id => id
			Specialty.create :type => i, :count => 999, :player_id => id
		end
		Item.create :item_type => 9, :item_category => 1, :player_id => id
	end

	def after_delete
		vil = village
		vil.delete if vil
		%w(dinosaurs technologies specialties items league_applys buffs gods troops).each do |coll|
			self.send(coll).map(&:delete)
		end
		AdviseRelation.find(:employer_id => id).union(:advisor_id => id).each(&:delete)
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

end
