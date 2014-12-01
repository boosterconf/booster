Booster2013::Application.routes.draw do

  resources :timeslots

  resources :reviews


  get 'users/ref/:reference' => 'users#from_reference', :as => :user_from_reference
  get 'users/new_skeleton' => 'users#new_skeleton', :as => :new_skeleton_user
  post 'users/create_skeleton' => 'users#create_skeleton', :as => :create_skeleton_user

  get 'users/group_registration' => 'users#group_registration', :as => :new_group_registration
  post 'users/create_group_registration' => 'users#create_group_registration', :as => :create_group_registration

  get 'users/current/attending_dinner' => 'users#attending_dinner', :as => :attending_dinner_url
  get 'users/current/not_attending_dinner' => 'users#not_attending_dinner', :as => :not_attending_dinner_url

  get 'users/current/attending_speakers_dinner' => 'users#attending_speakers_dinner', :as => :attending_speakers_dinner_url
  get 'users/current/not_attending_speakers_dinner' => 'users#not_attending_speakers_dinner', :as => :not_attending_speakers_dinner_url


  get 'program/' => 'program#index'
  get 'program/lightningtalks1' => 'program#lightningtalks1'
  get 'program/lightningtalks2' => 'program#lightningtalks2'
  get 'program/workshops' => 'program#workshops'
  get 'program/lightning' => 'program#lightning'

  resources :users do
    collection do
      get :dietary_requirements
      get :phone_list
    end
  end

  resources :acceptances do
    member do
      get :accept
      get :refuse
      get :await
      get :confirm
      get :unconfirm
      get :send_mail
    end
  end

  resources :statistics, only: [:index] do
    get :users_by_company, on: :collection
  end

  resources :user_sessions

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout

  match 'registrations/send_welcome_email' => 'registrations#send_welcome_email', :as => :send_welcome_email_url
  match 'registrations/send_speakers_dinner_email' => 'registrations#send_speakers_dinner_email', :as => :send_speakers_dinner_email_url

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

  match '/workshops' => 'talks#workshops'
  match '/lightning_talks' => 'talks#lightning_talks'
  match '/talks/cheat_sheet' => 'talks#cheat_sheet'
  match '/talks/vote' => 'talks#vote'
  resources :talks do
    resources :comments
    resources :reviews
    member do
      get :article_tags
    end
  end

  namespace :api do
    resources :sponsors do
      post :email
    end
    match 'boosterbot/slash_bot' => 'boosterbot#slash_bot', :via => :post, :as => :slash_bot
  end

  resources :nametags

  resources :receipts

  resources :feedbacks

  resources :payment_notifications

  resources :password_resets

  resources :invoices do
    member do
      post :add_user
      post :remove_user
      post :invoiced
      post :paid
    end
  end

  resources :dinner do
    collection do
      post :attend_speakers_dinner
      post :attend_conference_dinner
    end
  end

  match '/register_lightning_talk/start' => 'register_lightning_talk#start'
  match '/register_lightning_talk/create_user' => 'register_lightning_talk#create_user'
  match '/register_lightning_talk/talk' => 'register_lightning_talk#talk'
  match '/register_lightning_talk/create_talk' => 'register_lightning_talk#create_talk'
  match '/register_lightning_talk/details' => 'register_lightning_talk#details'
  match '/register_lightning_talk/create_details' => 'register_lightning_talk#create_details'
  match '/register_lightning_talk/finish' => 'register_lightning_talk#finish'

  match '/register_workshop/start' => 'register_workshop#start'
  match '/register_workshop/create_user' => 'register_workshop#create_user'
  match '/register_workshop/talk' => 'register_workshop#talk'
  match '/register_workshop/create_talk' => 'register_workshop#create_talk'
  match '/register_workshop/details' => 'register_workshop#details'
  match '/register_workshop/create_details' => 'register_workshop#create_details'
  match '/register_workshop/finish' => 'register_workshop#finish'

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
  match 'info/openspaces' => 'info#openspaces'
  match 'info/fishbowl' => 'info#fishbowl'
  match 'info/conference_dinner' => 'info#conference_dinner'
  match 'info/coc' => 'info#coc'

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
