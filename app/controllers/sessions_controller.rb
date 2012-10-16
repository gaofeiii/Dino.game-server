include SessionsHelper

class SessionsController < ApplicationController

	skip_before_filter :find_player
	before_filter :get_device_token, :only => [:demo, :create, :register]


	# TODO:
	# 试玩
	def demo
		result = trying
		data = if result[:success]
			player = create_player(result[:account_id])
			{
				:message => "SUCCESS", 
				:player => player.to_hash(:all), 
				:username => result[:username],
				:password => result[:password]
			}
		else
			{:message => "SERVER_BUSY"}
		end
		render :json => data
	end

	# 登录
	def create
		rcv_msg = account_authenticate :username => params[:username], 
																	 :email 	 => params[:email], 
																	 :password => params[:password]
		data = {}
		if rcv_msg[:success]
			@player = Player.find(:account_id => rcv_msg[:account_id]).first
			if @player.nil?
				@player = create_player(rcv_msg[:account_id])
			else
				@player.set :device_token, @device_token
			end
			data = {:message => "LOGIN_SUCCESS", :player => @player.to_hash(:all)}
		else
			data = {:message => "LOGIN_FAILED"}
		end
		render :json => data
	end

	
	# 注册
	def register
		result = account_register :username => params[:username],
															:email 		=> params[:email],
															:password => params[:password],
															:password_confirmation => params[:password_confirmation]
		data = {}
		if result[:success]
			begin
				@player = create_player(result[:account_id], params[:username])
				data = {:message => 'REGISTER_SUCCESS', :player => @player.to_hash(:all)}
			rescue Exception => e
				data = {:message => format_error_message(e)}
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
		result = account_update :account_id => params[:account_id],
														:username		=> params[:username],
														:email 			=> params[:email],
														:password		=> params[:password],
														:password_confirmation => params[:password_confirmation]
		render :json => result
	end


	private

	def create_player(account_id, nickname = nil)
		n_name = nickname.nil? ? "Player^#{Digest::MD5.hexdigest(Time.now.utc.to_s + String.sample(6))[8, 6]}" : nickname
		Player.create :account_id => account_id, :nickname => n_name, :device_token => @device_token
	end

	def get_device_token
		@device_token = params[:device_token].to_s.delete('<').delete('>').delete(' ')
	end


end
