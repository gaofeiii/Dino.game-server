include SessionsHelper
class PlayersController < ApplicationController

	before_filter :validate_player, :only => [:refresh, :modify_nickname, :modify_password, :register_game_center, :harvest_all_goldmines]
	skip_filter :validate_session, :only => [:modify_nickname]

	def deny_access
		render :text => "Request denied." and return
	end

	def index
		player = Session.with(:session_key, params[:session_key]).try(:player)
		if player.nil?
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message("INVALID_PLAYER_ID")
				}, :status => 999 and return
		end
		render :json => {:player => player.to_hash(:all)}
	end

	def show
		player = Player[params[:id]]
		if player.nil?
			render :json => {:error => "Player not found"}, :status => 999 and return
		end
		render :json => {:player => player.to_hash(:all)}
	end

	def refresh
		data = {:message => Error.success_message, :player => @player.to_hash(:all)}
		render :json => data
	end

	def change_avatar
		if params[:avatar_id].to_i < 0
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message("INVALID_AVATAR_ID")
			}
			return
		end

		if Player.exists?(params[:player_id])
			Ohm.redis.hset(Player.key[params[:player_id]], :avatar_id, params[:avatar_id])
			render :json => { :message => Error.success_message }
		else
			render :json => {
				:message => Error.failed_message,
				:error_type => Error::NORMAL,
				:error => Error.format_message("INVALID_PLAYER_ID")
			}
		end
	end

	def my_gold_mines
		r_key = "GoldMine:indices:player_id:#{params[:player_id]}"
		player = Player.new(:id => params[:player_id])

		result = Ohm.redis.smembers(r_key).map do |g_id|
			mine = GoldMine[g_id]
			next unless mine

			mine.to_hash(:gold_inc => player.tech_gold_inc)
		end.compact

		player.get(:league_id)
		p player
		p player.league
		unless player.league_id.blank?
			p player.league.gold_mines.ids
			player.league.gold_mines.each do |league_mine|
				p league_mine
				result << league_mine.to_hash
			end
		end

		render :json => {
			:message => Error.success_message,
			:gold_mines => result
		}
	end
	
	# Some regular expressions
	EN_NAME_REG = /^[A-Za-z][A-Za-z0-9]{2,15}$/
	EN_CN_NAME_REG = /^[A-Za-z\u4E00-\uFA29][A-Za-z0-9\u4E00-\uFA29]{1,7}$/

	# Some regular expressions
	EN_NAME_REG = /^[A-Za-z][A-Za-z0-9]{2,15}$/
	EN_CN_NAME_REG = /^[A-Za-z\u4E00-\uFA29][A-Za-z0-9\u4E00-\uFA29]{1,7}$/

	def modify_nickname
		nkname = params[:nickname]
		if nkname.sensitive?
			render_error(Error::NORMAL, I18n.t('players_error.invalid_nickname')) and return
		end

		# 昵称检测：中文长度2-8，英文长度3-16
		if nkname =~ /[\u4E00-\uFA29]/
			valid = nkname =~ EN_CN_NAME_REG
		else
			valid = nkname =~ EN_NAME_REG
		end

		unless valid
			render_error(Error::NORMAL, I18n.t('players_error.invalid_nickname')) and return
		end

		if Player.find(:nickname => nkname).any?
			render_error(Error::NORMAL, I18n.t('login_error.duplicated_nickname')) and return
		end

		result = account_update :account_id => @player.account_id,
														:username => nkname,
														:password => params[:password]

		if result[:success]
			@player.update(:nickname => nkname, :is_set_nickname => true)
			@player.village.set(:name, I18n.t("player.whos_village", :locale => @player.locale, :player_name => nkname))
			render_success(:player => {:nickname => @player.nickname}, :username => @player.nickname)
		else
			render_error(Error::NORMAL, I18n.t('players_error.set_nickname_failed'))
		end
	end

	def register_game_center
		if Player.find(:gk_player_id => params[:gk_player_id]).blank?
			@player.update :gk_player_id => params[:gk_player_id]
			render_success(:player => @player.to_hash)
		else
			render_error(Error::NORMAL, "Failed")
		end
	end

	def harvest_all_goldmines
		count = @player.harvest_gold_mines_manual
		render_success(:player => @player.to_hash, :count => count)
	end
end
