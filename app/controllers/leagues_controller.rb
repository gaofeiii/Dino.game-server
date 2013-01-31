class LeaguesController < ApplicationController

	before_filter :validate_player, :only => [:create, :apply, :apply_list, :my_league_info, :member_list, :invite, :donate]
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
			render :json => {:error => "LEAGUE_NOT_FOUND"}
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
		if LeagueApply.create :player_id => @player.id, :league_id => @league.id
			render :json => {:message => "APPLY_SUCCESS"}
		else
			render :json => {:message => "APPLY_FAILED"}
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
																							:level => League.levels[:member]
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
			@league.increase(:contribution, count / League::DONATE_FACTOR)
			@league.increase(:xp, count / League::DONATE_FACTOR)
		end

		render_success :player => {
			:wood => @player.wood,
			:stone => @player.stone,
			:league => {:contribution => @league.contribution}
		}

	end
		

end
