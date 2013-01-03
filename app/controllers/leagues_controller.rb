class LeaguesController < ApplicationController

	before_filter :validate_player, :only => [:create, :apply, :apply_list, :my_league_info, :member_list]
	before_filter :validate_league, :only => [:apply]

	def create
		if @player.spend!(:gems => 10)
			# name = "League#{rand(1..10000000)}"
			name = params[:name]
			lg = League.create :name => name, :desc => params[:desc], :president_id => @player.id
			lms = LeagueMemberShip.create :player_id => @player.id, 
																		:league_id => lg.id, 
																		:level => LeagueMemberShip.levels[:president], 
																		:nickname => @player.nickname
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
			render :json => {:error => "LEAGUE_NOT_FOUND"}
		else
			render :json => {
				:player => {
					:league => {
						:apply_list => league.apply_list
					}
				}
			}
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
																							:nickname => player.nickname,
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
						:apply_list => aplly.league.apply_list
					}
				}
			}
		else
			render :json => {:error => "WRONG_ACT_TYPE"}
		end
	end

end
