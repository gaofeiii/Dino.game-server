class Player < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension
	
	include MailsModule
	# include BattleReport
	include PlayerExp

	include PlayerTechHelper
	include PlayerGodHelper
	# include PlayerAdvisorHelper
	include PlayerResourceHelper
	include PlayerCreepsHelper
	include PlayerHonourHelper
	include PlayerLuckyRewardHelper
	include PlayerBattleRankHelper
	include PlayerCaveHelper
	include PlayerLoginGiftHelper
	include PlayerShoppingHelper
	include PlayerVipHelper
	include PlayerLeagueHelper
	include PlayerTypeHelper
	include PlayerBillHelper
	include PlayerFoodHelper
	include PlayerGoldHelper
	include PlayerWorkersHelper
	include PlayerDinosaursHelper
	include PlayerVillageHelper
	include PlayerDealsHelper
	include PlayerIosHelper
	include PlayerItemsHelper
	include PlayerMailHelper
	include PlayerRewardHelper
	include PlayerAdvHelper

	include BeginningGuide
	include DailyQuest
	include KillBillQuest

	# Player的属性
	attribute :account_id, 		Type::Integer
	attribute :nickname
	attribute :level, 				Type::Integer

	attribute :adapt_level,		Type::Integer
	
	attribute :experience, 		Type::Integer
	attribute :device_token
	attribute :avatar_id, 		Type::Integer		# 玩家头像的id
	attribute :battle_power,	Type::Integer
	
	attribute :village_id, 		Type::Integer
	attribute :session_id, 		Type::Integer
	attribute :country_id, 		Type::Integer

	attribute :locale

	attribute :is_set_nickname, 	Type::Boolean

	attribute :vip_expired_time, 	Type::Integer

	attribute :last_login_time, 	Type::Integer

	attribute :has_lottery,				Type::Boolean

	attribute :session_key

	attribute :gk_player_id	# Game Center id

	attribute :get_rating_reward, 	Type::Boolean

	collection :dinosaurs, 				Dinosaur
	collection :technologies, 		Technology
	collection :specialties, 			Specialty
	collection :items, 						Item
	collection :troops,						Troops
	collection :gold_mines,				GoldMine
	collection :strategies, 			Strategy

	collection :beginner_guides,	BeginnerGuide

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
	index :gk_player_id
	index :device_token

	include PlayerBeginnerGuideHelper
	include PlayerSerialTaskHelper

	# Player's finding methods:
	def self.find_by_account_id(account_id)
		self.find(:account_id => account_id).first
	end

	def self.find_by_nickname(nkname)
		self.find(:nickname => nkname).first
	end

	def self.find_by_gk_player_id(gk_id)
		return nil if gk_id.blank?
		self.find(:gk_player_id => gk_id).first
	end

	def login!
		curr_time = ::Time.now.to_i

		todays_begin_time = ::Time.now.beginning_of_day.to_i

		check_rating
		
		self.login_days = 0 if curr_time - last_login_time > 1.day.to_i
		if last_login_time < todays_begin_time && curr_time > todays_begin_time
			self.has_lottery = true
			self.login_days += 1
		end
		self.sets :last_login_time => curr_time, :login_days => login_days, :has_lottery => has_lottery
	end

	def techs_info
		technologies.map do |tech|
			tech.update_status!
			self.gets(:level, :experience)
			tech.to_hash
		end
	end

	def dinosaurs_info
		dinosaurs.map do |dino|
			dino.update_status!
			dino.to_hash
		end
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
			:login_days => login_days,
			:has_lottery => has_lottery,
			:in_league => in_league?,
			:game_center_account => gk_player_id,
			:todays_count => todays_count,
			:total_match_count => 20
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
				hash[:advisors] = my_advisors.map(&:to_hash)
			when :beginning_guide
				has_beginning_guide = !beginning_guide_finished
				# has_beginning_guide = false
				hash[:has_beginning_guide] = has_beginning_guide
				hash[:beginning_guide] = current_guide if has_beginning_guide
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
				all_quests = []
				all_serial_tasks = my_serial_tasks
				all_quests += my_serial_tasks.select{|task| task.index <= 20006}

				all_quests += daily_quests_full_info 
				all_quests << curr_bill_quest_full_info
				all_quests += my_serial_tasks.select{|task| task.index > 20006}[0, 5]

				hash[:daily_quests] = all_quests.compact
			when :advisor_dino
				hash[:advisor_dino] = Dinosaur[9].to_hash
			end

		end
		return hash
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
				:rank => friend.my_battle_rank,
				:x => vil.x,
				:y => vil.y,
				:league_name => friend_league.name
			}
		end
	end

  def locale
  	case @attributes[:locale]
  	when 'cn', 'zh-Hans'
  		:cn
  	else
  		:en
  	end
  end

  def find_task_by_index(idx)
  	return unless idx

  	case idx
  	when 1..10000 # Daily Quests
  		find_daily_quest_by_index(idx)
  	when 10001..20000 # Bill Quests
  		curr_bill_quest
		when 20001..30000 # Serial Tasks
  		find_serial_task_by_index(idx)
  	end
  end

	# Callbacks
	protected

	def before_create
		return if player_type == TYPE[:npc]
		self.gold_coin = 5600
		self.gems = 2200
		self.wood = 5600
		self.stone = 5600
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
		Item.create :item_type => 1, :item_category => Item.categories[:egg], :player_id => id, :quality => 2
		Item.create :item_type => 2, :item_category => Item.categories[:egg], :player_id => id, :quality => 1
		Item.create :item_type => 3, :item_category => Item.categories[:egg], :player_id => id, :quality => 1
		Item.create :item_type => 4, :item_category => Item.categories[:egg], :player_id => id, :quality => 1
		Item.create :item_type => 3, :item_category => Item.categories[:scroll], :player_id => id
		# Item.create :item_type => 2, :item_category => Item.categories[:scroll], :player_id => id
		# Item.create :item_type => 3, :item_category => Item.categories[:scroll], :player_id => id
		# Item.create :item_type => 4, :item_category => Item.categories[:scroll], :player_id => id
		# Item.create :item_type => 5, :item_category => Item.categories[:scroll], :player_id => id
		# Item.create :item_type => 6, :item_category => Item.categories[:scroll], :player_id => id
		
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
