require "budge_api/api"

Budge::Application.routes.draw do

  devise_for :users, :controllers => {:sessions => "sessions"}

  Rails.application.routes.draw do
    # oauth routes can be mounted to any path (ex: /oauth2 or /oauth)
    mount Devise::Oauth2Providable::Engine => '/oauth2'
  end

  match "/oauth/authorize", :via => :get, :to => "authorization#new"
  match "/oauth/authorize", :via => :post, :to => "authorization#create"

  get "dash/index"
  get "dash/users"
  get "dash/programs"
  get "dash/metrics"
  get "dash/debug"
  get "dash/social"

  mount BudgeAPI::API => "/"

  # Scaffold
  namespace :scaffold do
    # Admin
    resources :daily_grrs
    resources :nag_mode_prompts
    resources :nag_modes
    resources :user_nag_modes

    # Programs
    resources :programs
    resources :program_budges
    resources :program_players
    resources :player_budges
    resources :program_budge_templates
    resources :prompts
    resources :player_messages
    resources :leaders
    resources :link_resources
    resources :player_message_resources
    resources :program_link_resources
    resources :program_coaches
    resources :program_drafts
    resources :supporters
    resources :charges
  
    # Budge
    resources :entries
    resources :entry_comments
    resources :invitations
    resources :player_notes
    resources :twitter_scores
    resources :visit_stats
    resources :user_addons
    resources :addons
    resources :points
    resources :checkins
    resources :user_comments
    resources :user_likes
    resources :foursquare_categories
    resources :location_contexts
    resources :traits
    resources :stream_items
    resources :relationships
    resources :budge_requests
    resources :notifications
    resources :user_traits
    resources :user_budges
    resources :pack_traits
    resources :packs
    resources :tracked_actions
    resources :users
    resources :oauth_tokens
  end  
  
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  match 'apply/:id' => 'waiting_room#application'
  match 'ask/:id' => 'stream#view_budge_request'
  match 'b/:id' => 'stream#view_user_budge'
  match 's/:id' => 'stream#view'
  match 'n/:id' => 'stream#view_notification'
  match 'join/:id' => 'home#invitation'
  match '/@:id' => 'profile#t'
  match 'beta(/:id)' => 'home#flag_for_beta'
  match 'stream/filter(/:filter)' => 'stream#filter'
  match 'settings' => 'profile#settings'
  match 'tour' => 'home#tour'

  # Store stuff
  match '/store/pay/:id/:type(/:optional_id)' => 'store#pay'
  match '/store/pay_with_card/:id/:type(/:optional_id)' => 'store#pay_with_card'
  match '/store/pay_with_budge_dollars/:id/:type(/:optional_id)' => 'store#pay_with_budge_dollars'
  match '/store/payment_confirm/:id/:type(/:optional_id)' => 'store#payment_confirm'

  # Twilio
  match '/twilio/robocall/:id(/:id2(/:id3))' => 'twilio#robocall'
  
  # Practice Changing
  match '/button' => 'practice_changing#button'

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
  # root :to => "home#index"
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
