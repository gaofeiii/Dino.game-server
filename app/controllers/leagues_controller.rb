class LeaguesController < ApplicationController

	before_filter :validate_player, :only => [:create, :apply, :apply_list, :my_league_info, :member_list, 
		:invite, :donate, :receive_gold, :kick_member]
	before_filter :validate_league, :only => [:apply, :donate]

	def create
		if League.exists?(@player.league_id)
			render_error(Error::NORMAL, "YOU_ARE_ALREADY_IN_A_LEAGUE") and return
		end

		if @player.spend!(:gems => 10)
			# name = "League#{rand(1..10000000)}"
			name = params[:name]
			lg = League.create :name => name, :desc => params[:desc], :president_id => @player.id
			lms = LeagueMemberShip.create :player_id => @player.id, 
																		:league_id => lg.id, 
																		:level => LeagueMemberShip.levels[:president]
			@player.update :league_id => lg.id, :league_member_ship_id => lms.id
			render :json => {:player => {:league => lg.to_hash}}
		else
			render :json => {:error => "NOT_ENOUGH_SUNS"}
		end
	end

	def search
		keys = Ohm.redis.keys("League:indices:name:*#{params[:keyword]}*")

		leagues = if keys.blank?
			[]
		else
			Ohm.redis.sunion(keys).map do |lid|
				League[lid].to_hash
			end
		end

		render :json => {:leagues_list => leagues}
	end

	def my_league_info
		league = @player.league
		if league.nil?
			render :json => {:player => {:league => {}}}
		else
			render :json => {
				:player => {
					:league => league.to_hash
				}
			}
		end
	end

	def member_list
		league = @player.league
		if league.nil?
			render :json => {:error => I18n.t('league_error.not_in_a_league')}
		else
			render :json => {
				:player => {
					:league => {
						:members_list => @player.league.members_list
					}
				}
			}
		end
	end

	def apply
		@president = @league.president
		mail = Mail.create_league_apply_mail  :president 		=> @president.nickname,
																					:player_name 	=> @player.nickname,
																					:player_id 		=> @player.id,
																					:league_id 		=> @league.id,
																					:league_name 	=> @league.name,
																					:locale 			=> @president.locale,
																					:receiver_id	=> @president.id

		if mail
			render_success
		else
			render_error(Error::NORMAL, I18n.t('general.apply_league_fail'))
		end
	end

	def apply_list
		league = @player.league
		if league.nil?
			render_error(Error.types[:normal], I18n.t("league_error.LEAGUE_NOT_FOUND", :locale => @player.locale))
		else
			render_success(:apply_list => league.apply_list)
		end
		
	end

	def handle_apply
		apply = LeagueApply[params[:apply_id]]

		if apply.nil?
			render :json => {:message => "APPLY_ALREADY_HANDLED"} and return
		end

		act = params[:act].to_i
		case act
		when 1
			apply.mutex do
				player = apply.player
				membership = LeagueMemberShip.create 	:player_id => apply.player_id,
																							:league_id => apply.league_id,
																							:level => League.positions[:member]
				player.update :league_id => apply.league_id, :league_member_ship_id => membership.id
				render :json => {
					:player => {
						:league => player.to_hash(:league)
					}
				}
			end
		when 0
			apply.mutex do
				apply.delete
			end
			render :json => {
				:player => {
					:league => {
						:apply_list => apply.league.apply_list
					}
				}
			}
		else
			render :json => {:error => "WRONG_ACT_TYPE"}
		end
	end

	def invite
		@league = @player.league
		if @league.nil?
			render_error(Error::NORMAL, "You are not in a league") and return
		end

		@friend = Player[params[:friend_id]]
		if @friend.nil?
			render_error(Error::NORMAL, "Invalid friend id") and return
		end

		mail = Mail.create_league_invite_mail(:receiver_name => @friend.nickname, :player_name => @player.nickname, :league_name => @league.name, :league_id => @league.id)
		
		if mail
			render_success
		else
			render_error(Error::NORMAL, I18n.t('general.server_busy'))
		end
	end
	
	def accept_invite
		# already validated @player
		@mail = Mail[params[:mail_id]]
		if @mail.nil?
			render_error(Error::NORMAL, "Invalid mail id") and return
		end

		@league = @mail.league
		if @league.nil?
			render_error(Error::NORMAL, "League not exists") and return
		end

		if @league.add_new_member(@player)
			render_success(:player => @player.to_hash)
		else
			render_error(Error::NORMAL, I18n.t('general.server_busy'))
		end
	end
	
	def refuse_invite
	end

	def donate
		donate_type = params[:type].to_i
		if donate_type <= 0 || donate_type > 2
			render_error(Error::NORMAL, "Invalid resource type") and return
		end

		count = params[:count].to_i
		if count <= League::DONATE_FACTOR * 10
			render_error(Error::NORMAL, "Count must greater than #{League::DONATE_FACTOR * 10}") and return
		end

		cost = case donate_type
		when League::DONATE_TYPE[:wood]
			{:wood => count}
		when League::DONATE_TYPE[:stone]
			{:stone => count}
		end

		if @player.spend!(cost)
			@player.league_member_ship.increase(:contribution, count / 1000)
			@league.increase(:contribution, count / League::DONATE_FACTOR)
			@league.increase(:xp, count / League::DONATE_FACTOR)
		end

		data = {
			:player => @player.to_hash.merge(:league => @league.to_hash.merge(:members_list => @league.members_list))
		}
		render_success data

		# render_success :player => {
		# 	:wood => @player.wood,
		# 	:stone => @player.stone,
		# 	:league => {:contribution => @league.contribution}
		# }

	end

	def receive_gold
		membership = @player.league_member_ship

		if membership.nil?
			render_error(Error::NORMAL, I18n.t('league_error.not_in_a_league')) and return
		end

		if membership.contribution <= 10
			render_error(Error::NORMAL, I18n.t('league_error.contribution_count_is_zero')) and return
		end

		if membership.increase(:contribution, -100)
			gold = @player.league.harvest_gold
			@player.receive!(:gold => gold)
			render_success(:player => @player.to_hash(:league), :info => I18n.t("general.get_league_gold_success", :gold_count => gold))
		else
			render_error(Error::NORMAL, "Unknown League Error")
		end
	end

	def kick_member
		player_relation = LeagueMemberShip[Player.get(params[:player_id], :league_member_ship_id)]

		if player_relation.nil?
			render_error(Error::NORMAL, "u r not a league member") and return
		end

		if player_relation.level != LeagueMemberShip::LEVELS[:president]
			render_error(Error::NORMAL, "only president can do it") and return
		end

		member_relation = LeagueMemberShip[Player.get(params[:member_id], :league_member_ship_id)]

		if member_relation.nil?
			render_error(Error::NORMAL, "member is not in league") and return
		end

		if member_relation.league_id.to_i != params[:league_id].to_i
			render_error(Error::NORMAL, "you have no right to do it") and return
		end

		member_relation.delete
		member_relation.player.update :league_id => nil

		render_success(:player => @player.to_hash(:league))
	end
		

end
