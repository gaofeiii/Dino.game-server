class FriendsController < ApplicationController
	before_filter :validate_player, :only => [:add_friend, :friend_list, :remove_friend]
	before_filter :validate_friend, :only => [:add_friend, :remove_friend]

	def search_friend
		# TODO: Should not use 'keys' method.
		ids = Ohm.redis.keys("Player:indices:nickname:*#{params[:name]}*").map do |key|
			Ohm.redis.smembers(key)
		end.flatten

		result = ids.map do |id|
			player = Player.new :id => id
			player.gets(:nickname, :level, :score, :player_type)
			rank = rand(1..1000)
			if !player.is_npc?
				{
					:id => id.to_i,
					:nickname => player.nickname,
					:level => player.level,
					:score => player.score,
					:rank => rank
				}
			end
		end.compact

		render :json => {:result => result}
	end

	def random_friends
		result = Ohm.redis.srandmembers(Player.all.key, 5).map do |p_id|
			info = Player.gets(p_id, :nickname, :level, :score, :avatar_id)
			rank = rand(1..1000)
			{
				:id => p_id.to_i,
				:nickname => info[0],
				:level => info[1].to_i,
				:score => info[2].to_i,
				:rank => rank,
				:avatar_id => info[3].to_i
			}
		end

		render :json => {
			:message => Error.success_message,
			:result => result
		}
	end

	def add_friend
		friend = Player[params[:friend_id]]

		if friend.nil?
			render :json => {:error => "FRIEND_NOT_FOUND"} and return
		end

		data = if @player.friends.add(friend)
			render_success#(:player => {:friends => @player.friend_list})
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
			render :json => {:error => "FRIEND_NOT_FOUND"} and return
		end

		data = if @player.friends.delete(friend)
			{:player => {:friends => @player.friend_list}}
		else
			{:error => "REMOVE_FRIEND_FAILED"}
		end
		render :json => data
	end

	def validate_friend
		
	end
end
