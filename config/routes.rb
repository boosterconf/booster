Rails.application.routes.draw do

  require 'sidekiq/web'

  authenticate :user, lambda { |u| u.is_admin } do
    mount Sidekiq::Web => '/sidekiq'
  end
  devise_for :users
  get '/.well-known/acme-challenge/T0USF7R5JLNo9xygAzV_mHXxetcd2HLWD3Gjz3uNSiU' => 'pages#letsencrypt'

  resources :tickets do
    collection do
      get :send_ticket_email
      get :download_emails
    end
  end
  resources :orders, param: :reference do
    resource :invoice, only: [:new, :create]
    resource :direct_payment, only: [:new, :completed] do
      get :completed
    end
  end
  post "/direct_payment/webhook" => "direct_payments#webhook"
  resources :rooms
  resources :periods
  resources :slots
  resources :reviews
  resources :ticket_types
  resources :group_registrations, only: [:new, :create]

  get 'tickets/ref/:reference' => 'tickets#from_reference', :as => :tickets_from_reference
  patch 'tickets/ref/:reference' => 'tickets#create_from_reference', :as => :tickets_create_from_reference

  get 'users/ref/:reference' => 'users#from_reference', :as => :user_from_reference
  get 'users/new_skeleton' => 'users#new_skeleton', :as => :new_skeleton_user
  post 'users/create_skeleton' => 'users#create_skeleton', :as => :create_skeleton_user

  get 'users/current/attending_dinner' => 'users#attending_dinner', :as => :attending_dinner_url
  get 'users/current/not_attending_dinner' => 'users#not_attending_dinner', :as => :not_attending_dinner_url

  get 'users/current/attending_speakers_dinner' => 'users#attending_speakers_dinner', :as => :attending_speakers_dinner_url
  get 'users/current/not_attending_speakers_dinner' => 'users#not_attending_speakers_dinner', :as => :not_attending_speakers_dinner_url
  get 'users/index' => 'users#index'

  get 'program/' => 'program#index'
  get 'program/lightningtalks1' => 'program#lightningtalks1'
  get 'program/lightningtalks2' => 'program#lightningtalks2'
  get 'program/workshops' => 'program#workshops'
  get 'program/lightning' => 'program#lightning'
  get '/blifrivillig', to: 'blifrivillig#get'

  resources :users

  resources :acceptances do
    member do
      get :accept
      get :refuse
      get :pending
      get :confirm
      get :could_not_attend
      get :unconfirm
      get :send_mail
    end
    collection do
      post :create_tickets
      post :create_tickets_organizers
      get :download_speakers_list
    end
  end

  resources :statistics, only: [:index] do
    get :users_by_company, on: :collection
  end

  # resources :user_sessions

  match 'registrations/send_welcome_email' => 'registrations#send_welcome_email', :as => :send_welcome_email_url, via: :all
  match 'registrations/send_speakers_dinner_email' => 'registrations#send_speakers_dinner_email', :as => :send_speakers_dinner_email_url, via: :all

  resources :users do
    get :deleted, on: :collection
    member do
      get :restore
    end
  end

  resources :sponsors, except: [:show] do
    resources :events
    member do
      post :email
    end
    collection do
      post :email_tickets
    end
  end

  match '/workshops' => 'talks#workshops', via: :all
  match '/lightning_talks' => 'talks#lightning_talks', via: :all
  match '/talks/cheat_sheet' => 'talks#cheat_sheet', via: :all

  resources :talks do
    resources :reviews
    member do
      get :article_tags
    end
    collection do
      get :accepted
    end
  end

  namespace :api do
    resources :sponsors do
      post :email
    end
    resources :program do
      get :index
    end
    match 'boosterbot/slash_bot' => 'boosterbot#slash_bot', :via => :post, :as => :slash_bot
  end

  resources :nametags

  resources :receipts

  resources :password_resets


  resources :dinner do
    collection do
      post :attend_speakers_dinner
      post :attend_conference_dinner
    end
  end

  match '/register_lightning_talk/start' => 'register_lightning_talk#start', via: :all
  match '/register_lightning_talk/create_user' => 'register_lightning_talk#create_user', via: :all
  match '/register_lightning_talk/talk' => 'register_lightning_talk#talk', via: :all
  match '/register_lightning_talk/create_talk' => 'register_lightning_talk#create_talk', via: :all
  get   '/register_lightning_talk/invited_talk' => 'register_lightning_talk#invited_talk', as: "register_invited_lightning_talk"
  post  '/register_lightning_talk/invited_talk' => 'register_lightning_talk#create_invited_talk'
  match '/register_lightning_talk/details' => 'register_lightning_talk#details', via: :all
  match '/register_lightning_talk/create_details' => 'register_lightning_talk#create_details', via: :all
  match '/register_lightning_talk/finish' => 'register_lightning_talk#finish', via: :all

  match '/register_workshop/start' => 'register_workshop#start', via: :all
  match '/register_workshop/create_user' => 'register_workshop#create_user', via: :all
  match '/register_workshop/talk' => 'register_workshop#talk', via: :all
  match '/register_workshop/create_talk' => 'register_workshop#create_talk', via: :all
  get   '/register_workshop/invited_talk' => 'register_workshop#invited_talk', as: "register_invited_workshop"
  post  '/register_workshop/invited_talk' => 'register_workshop#create_invited_talk'
  match '/register_workshop/details' => 'register_workshop#details', via: :all
  match '/register_workshop/create_details' => 'register_workshop#create_details', via: :all
  match '/register_workshop/finish' => 'register_workshop#finish', via: :all

  match '/register_short_talk/start' => 'register_short_talk#start', via: :all
  match '/register_short_talk/create_user' => 'register_short_talk#create_user', via: :all
  match '/register_short_talk/talk' => 'register_short_talk#talk', via: :all
  match '/register_short_talk/create_talk' => 'register_short_talk#create_talk', via: :all
  get   '/register_short_talk/invited_talk' => 'register_short_talk#invited_talk', as: "register_invited_short_talk"
  post  '/register_short_talk/invited_talk' => 'register_short_talk#create_invited_talk'
  match '/register_short_talk/details' => 'register_short_talk#details', via: :all
  match '/register_short_talk/create_details' => 'register_short_talk#create_details', via: :all
  match '/register_short_talk/finish' => 'register_short_talk#finish', via: :all


  get   '/register_keynote/invited_talk' => 'register_keynote#invited_talk', as: "register_invited_keynote"
  post  '/register_keynote/invited_talk' => 'register_keynote#create_invited_talk'

#match 'login' => 'user_sessions#new', :as => :login
#match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'users/current' => 'users#current', :as => :current_user, via: :all
  match 'users/:id/create_bio' => 'users#create_bio', via: :all
  match 'users/:id/delete_bio' => 'users#delete_bio', via: :all
  get 'users/:user_id/assign_talk' => 'talks#assign', as: :assign_talk
  post 'users/:user_id/assign_talk' => 'talks#create_assigned', as: :create_assigned_talk

  match 'info/organizers' => 'info#organizers', via: :all
  match 'info/monetary_policy' => 'info#monetary_policy', via: :all
  match 'info/cfp' => 'info#cfp', via: :all
  match 'info/partners' => 'info#partners', via: :all
  match 'info/about' => 'info#about', via: :all
  match 'info/kids' => 'info#kids', via: :all
  match 'info/speakers' => 'info#speakers', via: :all
  match 'info/openspaces' => 'info#openspaces', via: :all
  match 'info/fishbowl' => 'info#fishbowl', via: :all
  match 'info/conference_dinner' => 'info#conference_dinner', via: :all
  match 'info/coc' => 'info#coc', via: :all
  match 'info/agile-at-scale' => 'info#agileatscale', via: :get

  match 'admin' => 'admin#index', via: :all

  root :to => 'info#index' #'/' resolves to info/index.html

end
