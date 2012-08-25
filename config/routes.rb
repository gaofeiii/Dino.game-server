DinosaurGame::Application.routes.draw do
  # 账户模块
  match '/demo'        => 'sessions#demo',       :via => :post
  match '/login'       => 'sessions#create',     :via => :post
  match '/register'    => 'sessions#register',   :via => :post
  match '/logout'      => 'sessions#logout',     :via => :post
  match '/update'      => 'sessions#update',     :via => :post

  # 玩家信息
  resources :players, :only => [:index, :show] do
    resources :villages, :only => :index do
    end
  end

  match 'refresh' => 'players#refresh', :via => :post

  # 村庄建造相关
  match 'create_building' => 'buildings#create', :via => :post

  # 科技研究相关
  match 'research' => 'research#research', :via => :post

  # 即时信息的刷新
  match 'real_time' => 'real_time_info#refresh', :via => :post

  # 聊天
  match 'world_chat' => 'chat#world_chat', :via => :post
  match 'create_chat_message' => 'chat#create_chat_message', :via => :post

  # match 'get_techs' => 'info#get_techs', :via => :get

  
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
