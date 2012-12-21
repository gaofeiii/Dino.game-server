DinosaurGame::Application.routes.draw do
  # 账户模块
  scope :path => 'accounts', :as => 'accounts' do
    post 'demo'        => 'sessions#demo'     # 快速试玩
    post 'login'       => 'sessions#create'   # 登录
    post 'register'    => 'sessions#register' # 注册
    post 'logout'      => 'sessions#logout'   # 登出
    post 'update'      => 'sessions#update'   # 更新账户
  end

  # 玩家信息
  scope :path => 'players', :as => 'players' do
    post 'refresh' => 'players#refresh'
    post 'change_avatar' => 'players#change_avatar'
    post 'my_gold_mines' => 'players#my_gold_mines'
  end
  

  # 村庄建造相关
  scope :path => 'buildings', :as => 'buildings' do
    post 'create'   => 'buildings#create'
    post 'speed_up' => 'buildings#speed_up'
    post 'move'     => 'buildings#move'
    post 'destroy'  => 'buildings#destroy'
    post 'complete' => 'buildings#complete'
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
  end

  # 恐龙相关
  scope :path => 'dinosaurs', :as => 'dinosaurs' do
    post 'update_status'    => 'dinosaur#update'
    post 'hatch_speed_up'   => 'dinosaur#hatch_speed_up'
    post 'feed'             => 'dinosaur#feed'
    post 'heal'             => 'dinosaur#heal'
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
    post 'receive_mail' => 'mails#receive_mails'
    post 'check_new_mails' => 'mails#check_new_mails'
    post 'mark_as_read' => 'mails#mark_as_read'
    post 'read_mail'    => 'mails#read_mail'
    post 'delete_mail'  => 'mails#delete_mail'
  end

  # 神灵
  scope :path => 'gods', :as => 'gods' do
    post 'worship'         => 'god#worship_gods'
    post 'cancel_worship'  => 'god#cancel_worship_gods'
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
  end

  # 排行榜
  scope :path => 'rank', :as => 'rank' do
    post 'score_rank'     => 'rank#score_rank'
    post 'battle_rank'    => 'rank#battle_rank'
  end

  # 防守策略
  scope :path => 'strategy', :as => 'strategy' do
    post 'set_defense'    => 'strategy#set_defense'
    post 'attack'         => 'strategy#attack'
    post 'refresh_battle' => 'strategy#refresh_battle'
    post 'get_battle_report' => 'strategy#get_battle_report'
  end

  # 商城
  scope :path => 'shopping', :as => 'shopping' do
    post 'buy_resource'     => 'shopping#buy_resource'
    post 'buy_gems'         => 'shopping#buy_gems'
    post 'buy_item'         => 'shopping#buy_item'
  end

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
