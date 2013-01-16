Booster2013::Application.routes.draw do

  resources :users
  resources :acceptances do
    member do
      get :accept
      get :refuse
      get :await
      get :send_mail
    end
  end

  get 'users/ref/:reference' => 'users#from_reference', :as => :user_from_reference

  resources :user_sessions

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout

  resources :registrations do
    member do
      get :confirm_delete
    end
  end

  resources :sponsors do
    resources :events
    member do
      post :email
    end
  end

  resources :talks do
    resources :comments
    member do
      get :article_tags
    end
  end

  resources :nametags

  resources :payment_notifications

  resources :password_resets


  match '/register_lightning_talk/start' => 'register_lightning_talk#start'
  match '/register_lightning_talk/create_user' => 'register_lightning_talk#create_user'
  match '/register_lightning_talk/talk' => 'register_lightning_talk#talk'
  match '/register_lightning_talk/create_talk' => 'register_lightning_talk#create_talk'
  match '/register_lightning_talk/details' => 'register_lightning_talk#details'
  match '/register_lightning_talk/create_details' => 'register_lightning_talk#create_details'
  match '/register_lightning_talk/finish' => 'register_lightning_talk#finish'

  match '/register_workshop/start'          => 'register_workshop#start'
  match '/register_workshop/create_user'    => 'register_workshop#create_user'
  match '/register_workshop/talk'           => 'register_workshop#talk'
  match '/register_workshop/create_talk'    => 'register_workshop#create_talk'
  match '/register_workshop/details'        => 'register_workshop#details'
  match '/register_workshop/create_details' => 'register_workshop#create_details'
  match '/register_workshop/finish'         => 'register_workshop#finish'

  #match 'login' => 'user_sessions#new', :as => :login
  #match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'users/current' => 'users#current', :as => :current_user
  match 'users/:id/create_bio' => 'users#create_bio'
  match 'users/:id/delete_bio' => 'users#delete_bio'

  match 'info/organizers' => 'info#organizers'
  match 'info/monetary_policy' => 'info#monetary_policy'
  match 'info/cfp' => 'info#cfp'
  match 'info/sponsors' => 'info#sponsors'
  match 'info/about' => 'info#about'
	match 'info/tickets' => 'info#tickets'
  match 'info/speakers' => 'info#speakers'

  match 'admin' => 'admin#index'

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  root :to => 'info#index' #'/' resolves to info/index.html

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


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
