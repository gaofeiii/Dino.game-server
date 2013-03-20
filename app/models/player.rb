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

	include DailyQuest
	include PlayerTechHelper
	include PlayerGodHelper
	include PlayerAdvisorHelper
	include PlayerResourceHelper
	include PlayerCreepsHelper
	include PlayerHonourHelper
	include PlayerLuckyRewardHelper
	include PlayerBattleRankHelper
	include KillBillQuest

	TYPE = {
		:normal => 0,
		:vip => 1,
		:npc => 2,
		:bill => 3
	}

	# Player的属性
	attribute :account_id, 		Type::Integer
	attribute :nickname
	attribute :level, 				Type::Integer

	attribute :adapt_level,		Type::Integer
	
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

	attribute :vip_expired_time, 	Type::Integer

	attribute :last_login_time, 	Type::Integer


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

	def is_vip?
		player_type == TYPE[:vip]
	end

	def is_bill?
		player_type == TYPE[:bill]
	end

	def self.none_npc
		self.find(:player_type => TYPE[:normal]).union(:player_type => TYPE[:vip])
	end

	def self.bill
		@@bill ||= self.find(:player_type => TYPE[:bill]).first
		@@bill
	end

	def self.bill_village
		@@bill_village ||= self.bill.village
		@@bill_village
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

	def login!
		self.set :last_login_time, ::Time.now.to_i
	end

	def in_league?
		!league_id.blank?
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
			:player_power => honour_score,
			:is_set_nickname => is_set_nickname,
			:dino_origin_capacity => tech_dinosaurs_size,
			:dino_ext_capacity => dinosaurs_capacity,
			:dinosaurs_capacity => dinosaurs_capacity + tech_dinosaurs_size,
			:dinosaurs_count => dinosaurs.size,
			:wood => wood,
			:stone => stone,
			:player_type => player_type,
			:warehouse_size => tech_warehouse_size,
			:tax_rate => Deal::ORIGIN_TAX,
			:in_league => in_league?
		}
		opts = if args.include?(:all)
			args | [:league, :god, :troops, :specialties, :village, :techs, :dinosaurs, :advisors, :beginning_guide, :queue_info]
		else
			args
		end

		opts.each do |att|
			case att
			when :village
				hash[:village] = village.to_hash(:all)
			when :techs
				hash[:techs] = techs_info
				hash[:level] = level
				hash[:experience] = experience
			when :dinosaurs
				hash[:dinosaurs] = dinosaurs_info
			when :items
				hash[:items] = items.map{|i| i.to_hash}
			when :specialties
				hash[:food] = specialties.map{|s| s.to_hash}
			when :league
				hash[:league] = league.try(:to_hash)
			when :advisors
				hash[:advisors] = my_advisors_info
			when :beginning_guide
				has_beginning_guide = !beginning_guide_finished
				# has_beginning_guide = false
				hash[:has_beginning_guide] = has_beginning_guide
				hash[:beginning_guide] = guide_info.current if has_beginning_guide
			when :queue_info
				hash[:max_queue_size] = action_queue_size
				hash[:queue_in_use] = curr_action_queue_size
			when :new_mails
				hash[:mail_status] = check_mails
			when :troops
				hash[:troops] = troops
			when :god
				if curr_god && !curr_god.expired?
					hash[:god] = curr_god.to_hash
				end
			when :daily_quest
				reset_daily_quest!
				hash[:daily_quests] = (daily_quests_full_info << curr_bill_quest_full_info).compact
			end

		end
		return hash
	end

	def techs_info
		technologies.map do |tech|
			tech.update_status!
			self.gets(:level, :experience)
			tech.to_hash
		end
	end

	def can_get_league_gold
		@league = League.new(:id => league_id)

		if !@league.exists?
			return 0
		else
			return @league.harvest_gold
		end
	end

	def dinosaurs_info
		dinosaurs.map do |dino|
			dino.update_status!
			dino.to_hash
		end
	end

	def league_member_ship
		LeagueMemberShip[league_member_ship_id]
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
			vil = Village.new(:id => friend.village_id).gets(:x, :y)
			friend_league = League.new(:id => friend.league_id).gets(:name)
			{
				:id => friend.id.to_i,
				:nickname => friend.nickname,
				:level => friend.level,
				:rank => rand(1..1000),
				:x => vil.x,
				:y => vil.y,
				:league_name => friend_league.name
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
		bd_size = village.buildings.find(:type => Building.hashes[:residential], :status => Building::STATUS[:finished]).size
		self.tech_worker_number * bd_size
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
  	if @attributes[:locale].blank?
  		@attributes[:locale] = 'en'
  	end
  	@attributes[:locale]
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

  def update_adapt_level
  	dino_ids = self.dinosaurs.ids
  	return false if dino_ids.size <= 0
  	new_level = dino_ids.sum{|dino_id| db.hget("Dinosaur:#{dino_id}", :level).to_i} / dino_ids.size
  	if new_level <= 0
  		new_level = 1
  	end
  	self.set :adapt_level, new_level
  end

  def visit_info
		vil = self.village
		hash = self.to_hash
		hash[:village] = vil.to_hash
		hash[:village][:buildings] = vil.buildings.map { |bd| bd.to_hash(:steal_info) }
		hash
	end

	def buildings
		vil = Village.new(:id => village_id)
		vil.buildings
	end

	def refresh_village_status
		self.buildings.find(:type => 0).union(:type => 1, :village_id => village_id).each do |build|
			build.update_status!
		end

		self.dinosaurs.find(:status => 0).each do |dino|
			dino.update_status!
		end
	end

	def receive_reward!(reward)
		self.receive!(reward)
		self.earn_exp!(reward[:xp]) if reward.has_key?(:xp)

		if reward.has_key?(:items)
			reward[:items].each do |itm|
				if itm[:item_cat] = Item.categories[:food]
					self.receive_food!(itm[:item_type], itm[:item_count])
				else
					Item.create(:item_category => itm[:item_cat], :item_type => itm[:item_type], :player_id => id)
				end
			end
		end
	end

	# Return [x, y]
	def find_rand_coords(country = Country.first)
		start_x, start_y = 500, 500

		empty_town_nodes = country.town_nodes_info.keys - country.used_town_nodes
		factor = Country::COORD_TRANS_FACTOR


		# 55.step(499, 2) do |coord_fact|
		# 	min_x = start_x - coord_fact
		# 	max_x = start_x + coord_fact
		# 	min_y = start_y - coord_fact
		# 	max_y = start_y + coord_fact

		# 	all_points = ([min_x, max_x].product((min_y..max_y).to_a) + [min_y, max_y].product((min_x..max_x).to_a)).uniq

		# 	avai_nodes = all_points.map!{|point| point[0] + point[1] * factor} & empty_town_nodes

		# 	node = avai_nodes.sample
		# 	avai_nodes.delete(node)

		# 	until !node.in?(country.used_town_nodes)
		# 		if node
		# 			return [node % factor, node / factor]
		# 		end

		# 		if avai_nodes.empty?
		# 			break
		# 		else
		# 			node = avai_nodes.sample
		# 			avai_nodes.delete(node)
		# 		end
		# 	end

			
		# end

		rand_node = empty_town_nodes.sample
		[rand_node % factor, rand_node / factor]
		# [x, y]
	end

	def curr_goldmine_size
		return 5 if level <= 10
		return 5 + (level - 10) / 2
	end

	def harvest_gold_mines
		mines = self.gold_mines
		return false if mines.size < 0

		total = mines.sum do |mine|
			delta_t = (Time.now.to_i - mine.update_gold_time) / 3600.0
			harvest_gold_count = (delta_t * mine.output).to_i

			self.receive!(:gold => harvest_gold_count) if harvest_gold_count > 0
			harvest_gold_count.to_i
		end
		Mail.create_goldmine_total_harvest_mail :receiver_id 		=> @player.id,
																						:receiver_name 	=> @player.nickname,
																						:locale 				=> @player.locale,
																						:count 					=> total
	end	

	# Callbacks
	protected

	def before_create
		return if player_type == TYPE[:npc]
		self.gold_coin = 600
		self.gems = 200
		self.wood = 600
		self.stone = 600
		self.level = 1 if (level.nil? or level == 0)
		self.avatar_id = rand(1..12) if avatar_id.zero?
		self.country_id = Country.first.id
		self.vip_expired_time = ::Time.now.to_i
		self.adapt_level = 1 if adapt_level.zero?
	end

	def after_create
		return if player_type == TYPE[:npc]
		create_village

		# Initial eggs:
		Item.create :item_type => 1, :item_category => Item.categories[:egg], :player_id => id, :quality => 4
		Item.create :item_type => 2, :item_category => Item.categories[:egg], :player_id => id, :quality => 1
		Item.create :item_type => 3, :item_category => Item.categories[:egg], :player_id => id, :quality => 1
		Item.create :item_type => 4, :item_category => Item.categories[:egg], :player_id => id, :quality => 1

		# Initial food:
		(1..8).each do |i|
			Specialty.create :type => i, :count => 80, :player_id => id
		end
	end

	def after_delete
		vil = village
		vil.delete if vil
		%w(dinosaurs technologies specialties items league_applys gods troops).each do |coll|
			self.send(coll).map(&:delete)
		end
		db.zadd(Player.key[:battle_rank], self.honour_score, id)
	end

	private

	# 为新玩家创建村庄
	def create_village
		country = Country.first
		x, y = find_rand_coords(country)
		random_coord = x + y * Country::COORD_TRANS_FACTOR
		vil = Village.create :name => "#{self.nickname}'s village", :player_id => self.id, 
		:x => x, :y => y, :country_index => 1
		country.add_used_town_nodes(random_coord)
		self.set :village_id, vil.id
	end

end
