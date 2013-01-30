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
	include PlayerExp

	include RankModel

	include DailyQuest
	include PlayerTechHelper
	include PlayerGodHelper
	include PlayerAdvisorHelper
	include PlayerResourceHelper
	include PlayerCreepsHelper
	include PlayerHonourHelper

	TYPE = {
		:normal => 0,
		:vip => 1,
		:npc => 2
	}

	# Player的属性
	attribute :account_id, 		Type::Integer
	attribute :nickname
	attribute :level, 				Type::Integer
	
	attribute :experience, 		Type::Integer
	attribute :device_token
	attribute :avatar_id, 		Type::Integer		# 玩家头像的id
	attribute :battle_power,	Type::Integer

	attribute :player_type, 	Type::Integer
	
	attribute :village_id, 		Type::Integer
	attribute :session_id, 		Type::Integer
	attribute :country_id, 		Type::Integer

	attribute :locale

	attribute :league_member_ship_id

	attribute :is_set_nickname, 	Type::Boolean

	attribute :dinosaurs_capacity, 		Type::Integer


	collection :dinosaurs, 				Dinosaur
	collection :technologies, 		Technology
	collection :specialties, 			Specialty
	collection :items, 						Item
	collection :league_applys, 		LeagueApply
	collection :troops,						Troops
	collection :deals,						Deal, 	:seller
	collection :gold_mines,				GoldMine
	collection :strategies, 			Strategy
	collection :app_store_orders,	AppStoreOrder

	reference :league, League
	
	set :friends, 				Player
	set :friend_invites, 	Player
	
	# indices
	index :account_id
	index :nickname
	index :level
	index :experience
	index :country_id
	index :player_type

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

	def to_hash(*args)
		hash = {
			:id => id.to_i,
			:nickname => nickname,
			:level => level,
			:gems => gems,
			:gold_coin => gold_coin,
			:experience => experience,
			:next_level_exp => next_level_exp,
			:account_id => account_id,
			:score => honour_score,
			:country_id => country_id.to_i,
			:avatar_id => avatar_id,
			:player_power => battle_power,
			:is_set_nickname => is_set_nickname,
			:dino_origin_capacity => tech_dinosaurs_size,
			:dino_ext_capacity => dinosaurs_capacity,
			:dinosaurs_capacity => dinosaurs_capacity + tech_dinosaurs_size,
			:dinosaurs_count => dinosaurs.size,
			:wood => wood,
			:stone => stone,
			:player_type => player_type,
			:warehouse_size => tech_warehouse_size,
			:tax_rate => Deal::ORIGIN_TAX
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
				hash[:advisors] = my_advisors_info
			when :beginning_guide
				has_beginning_guide = false#!beginning_guide_finished
				hash[:has_beginning_guide] = has_beginning_guide
				hash[:beginning_guide] = guide_info.current if has_beginning_guide
			when :queue_info
				hash[:max_queue_size] = action_queue_size
				hash[:queue_in_use] = curr_action_queue_size
			when :new_mails
				hash[:mail_status] = check_mails
			when :troops
				hash[:troops] = troops
			when :resources
				hash[:village] ||= {}
				hash[:village].merge!(:resources => village.resources)
			when :god
				if not gods.blank?
					hash[:god] = curr_god.to_hash
				end
			when :daily_quest
				reset_daily_quest!
				hash[:daily_quests] = daily_quests_full_info
			end

		end
		return hash
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
			{
				:id => friend.id.to_i,
				:nickname => friend.nickname,
				:level => friend.level,
				:score => friend.score,
				:rank => rand(1..1000),
				:x => 0,
				:y => 0
			}
		end
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
    result.deep_symbolize_keys
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

  def receive_food!(food_type, food_count = 0)
  	food = find_food_by_type(food_type)
  	if food.nil?
  		food = Specialty.create(:type => food_type, :count => food_count, :player_id => id)
  	else
  		food.increase(:count, food_count)
  	end
  end

  def next_dino_space_gems
  	case dinosaurs_capacity
  	when 0
  		1
  	when 1..4
  		dinosaurs_capacity * 5
  	when 5..9
  		(dinosaurs_capacity - 4) * 25
  	else
  		150
  	end
  end

  def released_dinosaurs_ids
  	db.smembers(key[:released_dinosaurs])
  end

  # 当前拥有的worker总数：民居数×科技
  def total_workers
  	vil = Village.new :id => village_id
  	tech_worker_number * vil.buildings.find(:type => Building.hashes[:residential]).size
  end

  # 当前正在工作的worker数
  def working_workers
  	vil = Village.new :id => village_id
  	vil.buildings.find(:has_worker => 1).size
  end

  def need_workers
  	vil = Village.new :id => village_id
  	vil.buildings.find(:resource_building => true).size
  end

  def update_building_workers!
  	vil = Village.new :id => village_id
  	total = total_workers
  	vil.buildings.find(:resource_building => true).each do |bd|
  		if total > 0
  			bd.update(:has_worker => 1)
  			total -= 1
  		else
  			bd.update(:has_worker => 0)
  		end
  	end
  end

  def village_level
  	(level / 10.0).ceil
  end

  def special_items
  	(items.find(:item_category => 4).ids + items.find(:item_category => 5).ids + items.find(:item_category => 6).ids).map do |item_id|
  		Item[item_id]
  	end
  end

	# Callbacks
	protected

	def before_create
		return if player_type == TYPE[:npc]
		self.gold_coin = 1000
		self.gems = 9999
		self.wood = 5000
		self.stone = 5000
		self.level = 1 if (level.nil? or level == 0)
		self.avatar_id = 1 if avatar_id.zero?
		self.country_id = Country.first.id
	end

	def after_create
		return if player_type == TYPE[:npc]
		create_village

		# TODO: == Just for Test ==
		1.upto(8) do |i|
			Item.create :item_type => i, :item_category => 1, :player_id => id
			Specialty.create :type => i, :count => 80, :player_id => id
		end
		Item.create :item_type => 9, :item_category => 1, :player_id => id
	end

	def after_delete
		vil = village
		vil.delete if vil
		%w(dinosaurs technologies specialties items league_applys gods troops).each do |coll|
			self.send(coll).map(&:delete)
		end
	end

	private

	# 为新玩家创建村庄
	def create_village
		random_coord = Country.first.town_nodes_info.keys.sample
		x = random_coord % Country::COORD_TRANS_FACTOR
		y = random_coord / Country::COORD_TRANS_FACTOR
		vil = Village.create :name => "#{self.nickname}'s village", :player_id => self.id, 
		:x => x, :y => y, :country_index => 1
		self.set :village_id, vil.id
	end

end
