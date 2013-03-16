include SessionsHelper
class PlayersController < ApplicationController

	before_filter :validate_player, :only => [:refresh, :modify_nickname, :modify_password]
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
		result = Ohm.redis.smembers(r_key).map do |g_id|
			next unless GoldMine.exists?(g_id)

			mine = GoldMine.new :id => g_id
			mine.gets(:x, :y, :type, :level, :player_id, :strategy_id)
			mine.to_hash
		end.compact

		render :json => {
			:message => Error.success_message,
			:gold_mines => result
		}
	end

	def modify_nickname
		nkname = params[:nickname]
		if nkname.sensitive?# || nkname =~ /[~!@#$\%^&*()_+|\[\];:\'\",.<>\/?\\\s。，、？！“”·：；‘]/
			render_error(Error::NORMAL, I18n.t('players_error.invalid_nickname')) and return
		end

		unless nkname =~ /[a-zA-Z0-9_]{4,16}/
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
end
