include SessionsHelper

class SessionsController < ApplicationController

	before_filter :get_device_token, :only => [:demo, :create, :register]
	before_filter :validate_player, :only => [:update]
	skip_filter :validate_session, :only => [:demo, :create, :register, :update]


	# 试玩
	def demo
		result = trying(:server_ip => params[:server_ip])
		data = if result[:success]
			player = create_player(result[:account_id])
			player.reset_daily_quest!
			player.refresh_village_status
			player.refresh_god_status!
			player.login!

			new_session_key = generate_session_key(player)
			player.set :session_key, new_session_key
			Session.set_player_session(player.id, new_session_key)
			
			Rails.logger.debug("*** New Player_id:#{player.id} ***")
			{
				:message => Error.success_message, 
				:player => player.to_hash(:all), 
				:username => result[:username],
				:password => result[:password],
				:session_key => player.session_key,
				:const_version => ServerInfo.const_version
			}
		else
			{
				:message => Error.failed_message,
				:error_type => Error::NORMAL
			}
		end
		render :json => data
	end

	# 登录
	def create
		rcv_msg = account_authenticate :username 	=> params[:username], 
																	 :email 	 	=> params[:email], 
																	 :password 	=> params[:password],
																	 :server_id => params[:server_id]
		data = {:const_version => ServerInfo.const_version}
		if rcv_msg[:success]
			@player = Player.find(:account_id => rcv_msg[:account_id]).first
			if @player.nil?
				@player = create_player(rcv_msg[:account_id])
			else
				@player.sets 	:device_token => @device_token,
											:locale => LocaleHelper.get_server_locale_name(request.env["HTTP_CLIENT_LOCALE"])
				@player.refresh_village_status
				@player.reset_daily_quest!
				@player.refresh_god_status!
			end
			@player.login!

			new_session_key = generate_session_key(@player)
			@player.set :session_key, new_session_key
			Session.set_player_session(@player.id, new_session_key)

			data.merge!({:message => Error.success_message, :player => @player.to_hash(:all), :session_key => new_session_key})
		else
			data.merge!({:message => Error.failed_message, :error => I18n.t('login_error.incorrect_username_or_password')})
		end
		render :json => data
	end

	
	# 注册
	def register
		result = account_register :username => params[:username],
															:email 		=> params[:email].blank? ? nil : params[:email],
															:password => params[:password],
															:password_confirmation => params[:password_confirmation],
															:server_id => params[:server_id]
		data = {:const_version => ServerInfo.const_version}
		if result[:success]
			begin
				@player = create_player(result[:account_id], params[:username])
				data.merge!({:message => 'SUCCESS', :player => @player.to_hash(:all)})
			rescue Exception => e
				data.merge!({:message => Error.format_message(e.to_s)})
			end
		else
			data = result
		end
		render :json => data
	end

	# 登出
	def logout
		
	end

	# 更新账号
	def update
		result = account_update :account_id => @player.account_id,
														:username		=> params[:username],
														:email 			=> params[:email],
														:password		=> params[:password],
														:password_confirmation => params[:password_confirmation]
		if result[:success]
			render_success(:password => params[:password])
		else
			render_error(Error::NORMAL, "Invalid password")
		end
	end

	def change_password
		username, old_pass, new_pass = params[:username], params[:old_pass], params[:new_pass]
		if username.blank? || old_pass.blank? || new_pass.blank?
			render_error(Error::NORMAL, I18n.t("login_error.empty_username_or_password")) and return
		end

		result = account_change_pass 	:username => username,
																	:old_pass => old_pass,
																	:new_pass => new_pass

		if result[:success]
			render_success(:password => new_pass)
		else
			render_error(Error::NORMAL, result[:error])
		end
	end


	private

	def create_player(account_id, nickname = nil)
		guest_id = Ohm.redis.get(Player.key[:id]).to_i + 1
		n_name = nickname.nil? ? "Player_#{guest_id}" : nickname
		Player.create :account_id => account_id, 
									:nickname => n_name, 
									:device_token => @device_token,
									:locale => LocaleHelper.get_server_locale_name(request.env["HTTP_CLIENT_LOCALE"])
	end

	def get_device_token
		@device_token = params[:device_token].to_s.delete('<').delete('>').delete(' ')
	end


end
