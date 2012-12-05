include SessionsHelper

class SessionsController < ApplicationController

	skip_before_filter :find_player
	before_filter :get_device_token, :only => [:demo, :create, :register]


	# TODO:
	# 试玩
	def demo
		result = trying(:server_id => params[:server_id])
		data = if result[:success]
			player = create_player(result[:account_id])
			Rails.logger.debug("*** New Player_id:#{player.id} ***")
			{
				:message => Error.success_message, 
				:player => player.to_hash(:all), 
				:username => result[:username],
				:password => result[:password],
				:const_version => ServerInfo.const_version
			}
		else
			{
				:message => Error.failed_message,
				:error_type => Error::TYPES[:normal]
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
				@player.set :device_token, @device_token
			end
			data.merge!({:message => Error.success_message, :player => @player.to_hash(:all)})
		else
			data.merge!({:message => Error.failed_message})
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
		result = account_update :account_id => params[:account_id],
														:username		=> params[:username],
														:email 			=> params[:email],
														:password		=> params[:password],
														:password_confirmation => params[:password_confirmation]
		render :json => result
	end


	private

	def create_player(account_id, nickname = nil)
		guest_id = Ohm.redis.get(Player.key[:id]).to_i + 1
		n_name = nickname.nil? ? "Player_#{guest_id}" : nickname
		Player.create :account_id => account_id, :nickname => n_name, :device_token => @device_token
	end

	def get_device_token
		@device_token = params[:device_token].to_s.delete('<').delete('>').delete(' ')
	end


end
