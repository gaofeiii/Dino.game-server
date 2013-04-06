module GameMailHelper

	module ClassMethods

		# ** 申请加为好友邮件 ** #
		def create_friend_application(player_id:nil, player_name:nil, friend_id:nil, friend_name:nil, locale:'en')
			return false unless (player_id && friend_id && player_name)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:friend_invite],
									:sender_id 			=> player_id,
									:sender_name 		=> player_name,
									:receiver_id 		=> friend_id,
									:receiver_name 	=> friend_name,
									:title 					=> I18n.t("mail.friend_invitation.title", :locale => locale),
									:content 				=> I18n.t('mail.friend_invitation.content', :locale => locale, :friend_name => player_name),
									:data 					=> {:player_id => player_id, :friend_id => friend_id}
		end

		# ** 公会邀请邮件 ** #
		def create_league_invitation(player_id:nil, player_name:nil, receiver_id:nil, receiver_name:nil, league_id:nil, league_name:nil, locale:'en')
			return false unless (player_id && player_name && receiver_id && league_id && league_name)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:league_invite],
									:sender_id 			=> 0,
									:sender_name 		=> I18n.t('system', :locale => locale),
									:receiver_id		=> receiver_id,
									:receiver_name 	=> receiver_name,
									:title 					=> I18n.t("mail.league_invitation.title", :league_name => league_name, :locale => locale),
									:content 				=> I18n.t('mail.league_invitation.content', :locale => locale, :player_name => player_name, :league_name => league_name),
									:data				 		=> {:player_id => player_id, :receiver_id => receiver_id, :league_id => league_id}
		end

		# ** 公会申请邮件 ** #
		def create_league_application(player_id:nil, player_name:nil, president_id:nil, president_name:nil, league_id:nil, league_name:nil, locale:'en')
			return false unless (player_id && player_name && president_id && league_id)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:league_apply],
									:sender_id			=> 0,
									:sender_name 		=> I18n.t('system', :locale => locale),
									:receiver_name 	=> args[:president],
									:title 					=> I18n.t("mail.league_application.title", :locale => locale),
									:content 				=> I18n.t('mail.league_application.content', :locale => locale, :player_name => player_name, :league_name => league_name),
									:data				 		=> {:player_id => player_id, :receiver_id => receiver_id, :league_id => league_id}
		end

		# ** 村落防守成功邮件 ** #
		def create_village_defense_win(attacker_id:nil, attacker_name:nil, defender_id:nil, defender_name:nil, x:nil, y:nil, locale:'en')
			return false unless (attacker_name && defender_id && defender_name && x && y)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:normal],
									:sender_id			=> 0,
									:sender_name 		=> I18n.t('system', :locale => locale),
									:receiver_id		=> defender_id,
									:receiver_name 	=> defender_name,
									:title 					=> I18n.t('mail.defense_village_win_mail.title', :locale => locale),
									:content				=> I18n.t('mail.defense_village_win_mail.content', :locale => locale, :x => x, :y => y, :attacker => attacker_name)
		end

		# ** 村落防守失败邮件 ** #
		def create_village_defense_lose(attacker_id:nil, attacker_name:nil, defender_id:nil, defender_name:nil, x:nil, y:nil, rate:0, locale:'en')
			return false unless (attacker_name && defender_id && defender_name && x && y)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:normal],
									:sender_id			=> 0,
									:sender_name 		=> I18n.t('system', :locale => locale),
									:receiver_id		=> defender_id,
									:receiver_name 	=> defender_name,
									:title 					=> I18n.t('mail.defense_village_lose_mail.title', :locale => locale),
									:content				=> I18n.t('mail.defense_village_lose_mail.content', :locale => locale, :x => x, :y => y, :attacker => attacker_name, :rate => rate)
		end

		# ** 挑战赛胜利邮件 ** #
		def create_match_win(attacker_id:nil, attacker_name:nil, defender_id:nil, defender_name:nil, score:0, locale:'en')
			return false unless (attacker_id && attacker_name && defender_id && score)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:normal],
									:sender_id			=> 0,
									:sender_name 		=> I18n.t('system', :locale => locale),
									:receiver_id		=> defender_id,
									:receiver_name 	=> defender_name,
									:title 					=> I18n.t('mail.match_win_mail.title', :locale => locale),
									:content				=> I18n.t('mail.match_win_mail.content', :locale => locale, :attacker => attacker_name, :score => score)
		end

		# ** 挑战赛失败邮件 ** #
		def create_match_lose(attacker_id:nil, attacker_name:nil, defender_id:nil, defender_name:nil, score:0, locale:'en')
			return false unless (attacker_id && attacker_name && defender_id && score)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:normal],
									:sender_id			=> 0,
									:sender_name 		=> I18n.t('system', :locale => locale),
									:receiver_id		=> defender_id,
									:receiver_name 	=> defender_name,
									:title 					=> I18n.t('mail.match_lose_mail.title', :locale => locale),
									:content				=> I18n.t('mail.match_lose_mail.content', :locale => locale, :attacker => attacker_name, :score => score)
		end

		# ** 防守金矿成功邮件 ** #
		def create_goldmine_defense_win(attacker_id:nil, attacker_name:nil, defender_id:nil, defender_name:nil, gx:0, gy:0, ax:0, ay:0, locale:'en')
			return false unless (attacker_id && attacker_name && defender_id && gx && gy && ax && ay)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:normal],
									:sender_id			=> 0,
									:sender_name 		=> I18n.t('system', :locale => locale),
									:receiver_id		=> defender_id,
									:receiver_name 	=> defender_name,
									:title 					=> I18n.t('mail.goldmine_defense_win.title', :locale => locale),
									:content				=> I18n.t('mail.goldmine_defense_win.content', :locale => locale, :attacker => attacker_name, :gx => gx, :gy => gy, :ax => ax, :ay => ay)
		end

		# ** 防守金矿失败邮件 ** #
		def create_goldmine_defense_lose(attacker_id:nil, attacker_name:nil, defender_id:nil, defender_name:nil, gx:0, gy:0, ax:0, ay:0, locale:'en')
			return false unless (attacker_id && attacker_name && defender_id && gx && gy && ax && ay)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:normal],
									:sender_id			=> 0,
									:sender_name 		=> I18n.t('system', :locale => locale),
									:receiver_id		=> defender_id,
									:receiver_name 	=> defender_name,
									:title 					=> I18n.t('mail.goldmine_defense_lose.title', :locale => locale),
									:content				=> I18n.t('mail.goldmine_defense_lose.content', :locale => locale, :attacker => attacker_name, :gx => gx, :gy => gy, :ax => ax, :ay => ay)
		end

		# ** 交易成功邮件 ** #
		def create_deal_succses_mail(buyer_id:nil, buyer_name:nil, seller_id:nil, seller_name:nil, gold:nil, goods_name:nil, count:0, locale:'en')
			return false unless (buyer_id && buyer_name && seller_name && gold && goods_name && count)

			self.create :mail_type 			=> GameMail::TYPE[:system],
									:sys_type 			=> GameMail::SYS_TYPE[:normal],
									:sender_id			=> 0,
									:sender_name 		=> I18n.t('system', :locale => locale),
									:receiver_name 	=> seller_name,
									:receiver_id		=> seller_id,
									:title 					=> I18n.t('mail.deal_success.title', :locale => locale),
									:content				=> I18n.t('mail.deal_success.content', :locale => locale, :buyer => buyer_name, :gold => gold, :goods_name => goods_name, :count => count)
		end

	end# == End of 'ClassMethods' ==
	
	
	module InstanceMethods
		
	end
	

	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end