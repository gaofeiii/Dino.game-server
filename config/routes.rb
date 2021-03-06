DinosaurGame::Application.routes.draw do
  # 账户模块
  scope :path => 'accounts', :as => 'accounts' do
    post 'demo'        => 'sessions#demo'             # 快速试玩
    post 'login'       => 'sessions#create'           # 登录
    post 'register'    => 'sessions#register'         # 注册
    post 'update'      => 'sessions#update'           # 更新账户
    post 'change_pass' => 'sessions#change_password'  # 修改密码
  end

  # 玩家信息
  scope :path => 'players', :as => 'players' do
    post 'refresh'                => 'players#refresh'
    post 'change_avatar'          => 'players#change_avatar'
    post 'my_gold_mines'          => 'players#my_gold_mines'
    post 'modify_nickname'        => 'players#modify_nickname'
    post 'register_game_center'   => 'players#register_game_center'
    post 'harvest_all_goldmines'  => 'players#harvest_all_goldmines'
  end

  # 村落
  scope :path => 'villages', :as => 'villages' do
    post 'move'         => 'villages#move'
    post 'visit_info'   => 'villages#visit_info'
    post 'steal'        => 'villages#steal'
  end
  

  # 村庄建造相关
  scope :path => 'buildings', :as => 'buildings' do
    post 'create'   => 'buildings#create'
    post 'speed_up' => 'buildings#speed_up'
    post 'move'     => 'buildings#move'
    post 'destroy'  => 'buildings#destroy'
    post 'complete' => 'buildings#complete'
    post 'harvest'  => 'buildings#harvest'
    post 'get_info' => 'buildings#get_info'
  end
  
  # 科技研究相关
  scope :path => 'techs', :as => 'techs' do
    post 'research' => 'research#research'
    post 'speed_up' => 'research#speed_up'
    post 'complete' => 'research#complete'
  end
  
  # 即时信息的刷新
  scope :path => 'const', :as => 'real_time_info' do
    post 'info' => 'real_time_info#info'
  end

  # 聊天
  scope :path => 'chats', :as => 'chats' do
    post 'world_chat'           => 'chat#world_chat'
    post 'create_chat_message'  => 'chat#create_chat_message'
  end

  # 物品相关
  scope :path => 'items', :as => 'items' do
    post 'items_list'   => 'items#my_items_list'
    post 'use'          => 'items#use'
    post 'food_list'    => 'items#food_list'
    post 'scrolls_list' => 'items#scrolls_list'
    post 'eggs_list'    => 'items#eggs_list'
    post 'lucky_reward' => 'items#lucky_reward'
    post 'special_items_list' => 'items#special_items_list'
    post 'drop'         => 'items#drop'
    post 'gift_lottery' => 'items#gift_lottery'
  end

  # 恐龙相关
  scope :path => 'dinosaurs', :as => 'dinosaurs' do
    post 'hatch'              => 'dinosaur#hatch'
    post 'update_status'      => 'dinosaur#update'
    post 'hatch_speed_up'     => 'dinosaur#hatch_speed_up'
    post 'feed'               => 'dinosaur#feed'
    post 'heal'               => 'dinosaur#heal'
    post 'release'            => 'dinosaur#release'
    post 'rename'             => 'dinosaur#rename'
    post 'reborn'             => 'dinosaur#reborn'
    post 'expand_capacity'    => 'dinosaur#expand_capacity'
    post 'refresh_all_dinos'  => 'dinosaur#refresh_all_dinos'
    post 'training'           => 'dinosaur#training'
    post 'evolution'          => 'dinosaur#evolution'

    post 'refresh_all_dinos_with_advisor'  => 'dinosaur#refresh_all_dinos_with_advisor'
    post 'refresh_all_dinos_with_goldmines' => 'dinosaur#refresh_all_dinos_with_goldmines'
    post 'refresh_all_dinos_with_arena_strategy' => 'dinosaur#refresh_all_dinos_with_arena_strategy'
  end
  
  # 公会
  scope :path => 'leagues', :as => 'leagues' do
    post 'create'         => 'leagues#create'
    post 'search'         => 'leagues#search'
    post 'member_list'    => 'leagues#member_list'
    post 'apply'          => 'leagues#apply'
    post 'handle_apply'   => 'leagues#handle_apply'
    post 'apply_list'     => 'leagues#apply_list'
    post 'my_league_info' => 'leagues#my_league_info'
    post 'invite'         => 'leagues#invite'
    post 'accept_invite'  => 'leagues#accept_invite'
    post 'refuse_invite'  => 'leagues#refuse_invite'
    post 'donate'         => 'leagues#donate'
    post 'receive_gold'   => 'leagues#receive_gold'
    post 'kick_member'    => 'leagues#kick_member'
    post 'leave_league'   => 'leagues#leave_league'
    post 'change_info'    => 'leagues#change_info'
  end  

  # 地图
  scope :path => 'map', :as => 'map' do
    post 'country_map'  => 'world_map#country_map'
    scope :path => 'country_map', :as => 'country_map' do
      post 'attack' => 'world_map#attack'
    end
  end

  # 好友
  scope :path => 'friends', :as => 'friends' do
    post 'add_friend'       => 'friends#add_friend'
    post 'remove_friend'    => 'friends#remove_friend'
    post 'friend_list'      => 'friends#friend_list'
    post 'search_friend'    => 'friends#search_friend'
    post 'random_friends'   => 'friends#random_friends'
    post 'apply_friend'     => 'friends#apply_friend'
    post 'apply_accept'     => 'friends#apply_accept'
    post 'apply_refuse'     => 'friends#apply_refuse'
  end

  # 顾问
  scope :path => 'advisors', :as => 'advisors' do
    post "advisor_list" => 'advisors#advisor_list'
    post "apply"        => 'advisors#apply'
    post "hire"         => 'advisors#hire'
    post "fire"         => 'advisors#fire'
  end

  # 邮件
  scope :path => 'mails', :as => 'mails' do
    post 'send_mail'    => 'mails#send_mail'
    post 'check_new_mails' => 'mails#check_new_mails'
    post 'mark_as_read' => 'mails#mark_as_read'
    post 'read_mail'    => 'mails#read_mail'
    post 'delete_mail'  => 'mails#delete_mail'
    post 'on_mail_ok'   => 'mails#on_mail_ok'
  end

  # 神灵
  scope :path => 'gods', :as => 'gods' do
    post 'worship'         => 'god#worship_gods'
    post 'cancel_worship'  => 'god#cancel_worship_gods'
    post 'query_god'       => 'god#query_god'
  end

  # 新手指引
  scope :path => 'guide', :as => 'guide' do
    post 'quest_complete' => 'guide#complete'
    post 'get_reward'     => 'guide#get_reward'
  end

  # 拍卖行相关方法(交易)
  scope :path => 'deals', :as => 'deals' do
    post 'list'    => 'deals#list'
    post 'buy'     => 'deals#buy'
    post 'sell'    => 'deals#sell'
    post 'my_selling_list' => 'deals#my_selling_list'
    post 'cancel_deal'  => 'deals#cancel_deal'
    post 'my_items_list' => 'deals#my_items_list'
  end

  # 排行榜
  scope :path => 'rank', :as => 'rank' do
    post 'player_rank'    => 'rank#player_rank'
    post 'league_rank'    => 'rank#league_rank'
  end

  # 防守策略
  scope :path => 'strategy', :as => 'strategy' do
    post 'set_defense'        => 'strategy#set_defense'
    post 'attack'             => 'strategy#attack'
    post 'refresh_battle'     => 'strategy#refresh_battle'
    post 'get_battle_report'  => 'strategy#get_battle_report'
    post 'match_players'      => 'strategy#match_players'
    post 'match_attack'       => 'strategy#match_attack'
    post 'set_match_strategy' => 'strategy#set_match_strategy'
    post 'league_goldmine_attack' => 'strategy#league_goldmine_attack'
    post 'give_up_goldmine'   => 'strategy#give_up_goldmine'
  end

  # 商城
  scope :path => 'shopping', :as => 'shopping' do
    post 'buy_gems'         => 'shopping#buy_gems'
    post 'buy'              => 'shopping#buy'
    post 'buy_arena_count'  => 'shopping#buy_arena_count'
  end

  # 日常任务
  scope :path => 'daily_quest', :as => 'daily_quest' do
    post 'refresh'   => 'daily_quest#refresh'
    post 'get_reward' => 'daily_quest#get_reward'
  end

  # 巢穴副本
  scope :path => 'cave', :as => 'cave' do
    post 'attack_cave'    => 'cave#attack_cave'
    post 'get_caves_info' => 'cave#get_caves_info'
  end

  # 金矿
  scope :path => 'gold_mine', :as => 'gold_mine' do
    post 'upgrade'    => 'gold_mine#upgrade'
  end

  match 'rating_us' => 'real_time_info#rating_us', :via => :post

  root :to => 'players#deny_access'

  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
