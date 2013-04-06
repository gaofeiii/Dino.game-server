class FriendsController < ApplicationController
	before_filter :validate_add_friend, :only => [:add_friend]
	before_filter :validate_player, :only => [:add_friend, :friend_list, :remove_friend, :apply_friend, :apply_accept, :apply_refuse]
	before_filter :validate_friend, :only => [:apply_friend, :add_friend]

	def search_friend
		# TODO: Should not use 'keys' method.
		ids = []
		if params[:name].blank?
			ids = Player.none_npc.ids.sample(10) # 限制空白搜索出来的玩家数
		else
			ids = Ohm.redis.keys("Player:indices:nickname:*#{params[:name]}*").map { |key| Ohm.redis.smembers(key) }.flatten
			ids = ids.sample(15) if ids.size > 15
		end

		result = ids.map do |id|
			player = Player.new :id => id
			player.gets(:nickname, :level, :player_type, :league_id, :honour_score)
			league_name = League.new(:id => player.league_id).get(:name)

			rank = player.my_battle_rank
			if !player.is_npc?
				{
					:id => id.to_i,
					:nickname => player.nickname,
					:level => player.level,
					:rank => rank,
					:league_name => league_name
				}
			end
		end.compact

		render :json => {:result => result}
	end

	def random_friends
		result = Ohm.redis.srandmembers(Player.all.key, 5).map do |p_id|
			player = Player.new(:id => p_id).gets(:nickname, :level, :avatar_id)
			rank = rand(1..1000)
			{
				:id => player.id,
				:nickname => player.nickname,
				:level => player.level,
				:rank => rank,
				:avatar_id => player.avatar_id
			}
		end

		render :json => {
			:message => Error.success_message,
			:result => result
		}
	end

	def add_friend

		data = if @player.friends.add(@friend)
			render_success
		else
			render_error(Error::NORMAL, I18n.t("friends_error.already_add_friend"))
		end
	end

	def friend_list
		render :json => {:player => {:friends => @player.friend_list}}
	end

	def remove_friend
		friend = Player[params[:friend_id]]

		if friend.nil?
			render :json => {:error => I18n.t('friends_error.friend_not_exist')} and return
		end

		data = if @player.friends.delete(friend)
			{:player => {:friends => @player.friend_list}}
		else
			{:error => "REMOVE_FRIEND_FAILED"}
		end
		render :json => data
	end

	def apply_friend
		if @player_id == @friend.id
			render_error(Error::NORMAL, "Cannot add yourself") and return
		end

		GameMail.create_friend_application 	:player_id 		=> @player.id,
																				:player_name 	=> @player.nickname,
																				:friend_id 		=> @friend.id,
																				:friend_name 	=> @friend.nickname,
																				:locale 			=> @friend.locale
		render_success
	end

	def apply_accept
		mail = Mail.new(:id => params[:mail_id]).gets(:cached_data)
		if mail
			@friend = Player.new(:id => mail.cached_data[:player_id]).gets(:nickname)
			if @player.friends.include?(@friend)
				render_error(Error::NORMAL, I18n.t('friends_error.already_add_friend', :friend_name => @friend.nickname)) and return
			end

			if @player.friends.add(@friend) && @friend.friends.add(@player)			
				render_success
			else
				render_error(Error::NORMAL, I18n.t('friends_error.add_friend_failed')) and return
			end
		else
			render_error(Error::NORMAL, I18n.t('friends_error.invitation_expired'))
		end
		
	end

	def apply_refuse
		@player.friend_invites.delete(@friend)
		render_success
	end

	private

	def validate_friend
		@friend = Player[params[:friend_id]]
		if @friend.nil?
			render_error(Error::NORMAL, "INVALID_FRIEND_ID")
			return
		end
	end

	def validate_add_friend
		if !params[:player_id].blank? && !params[:friend_id].blank? && params[:player_id] == params[:friend_id]
			render_error(Error::NORMAL, I18n.t('friends_error.cannot_add_self')) and return
		end
	end
end
