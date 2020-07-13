Rails.application.routes.draw do
  get 'add_detail/index'

  get 'occupancy/index'

  resources :dashboard
  resources :overview
  resources :occupancy
  resources :add_detail
  # resources :my_lists
  # resources :setup_topics
  # resources :templates
  # resources :custom_fields
  # resources :all_horses
  get 'dashboard/index'
 

  get 'reports/stables_report' , as: :stables_report
  get 'reports/users_report' , as: :users_report

  apipie

  root 'sessions#new'
  resources :sessions
  resources :subscription
  delete 'sessions' => 'sessions#destroy'
  resources :sign_ups
  resources :terms
  get 'accept_terms' => 'terms#accept_terms', as: :accept_terms
  post 'update_record' => 'terms#update_record', as: :update_record
  post 'check_coupon' => 'sign_ups#check_coupon', as: :check_coupon
  get 'download_pdf', to: "profile#download_pdf"
  match 'lang/:locale', to: 'language#change_locale', as: :change_locale, via: [:get]

  resources :users do
    get 'add' => 'users#add_user', as: :add_user
  end
  resources :profile
  post 'cancel_subscription' => 'subscription#cancel_subscription', as: :cancel_subscription
  post 'reactivate_subscription' => 'subscription#reactivate_subscription', as: :reactivate_subscription
  post 'make_new_subscription' => 'subscription#make_new_subscription', as: :make_new_subscription
  post 'change_credit_card' => 'subscription#change_credit_card', as: :change_credit_card
  post 'change_subscription' => 'subscription#change_subscription', as: :change_subscription
  resources :stables do
    get :generate_standard_templates
  end
  resources :horses do
    collection do
      get 'search'
      post 'import_single'
      post 'import_multiple'
      get 'horse_info/:id' => 'horses#horse_info', as: :horse_info
      get 'single_import_preview/:id' => 'horses#single_import_preview', as: :single_import_preview
      get 'multiple_import_preview/:trainer_id' => 'horses#multiple_import_preview', as: :multiple_import_preview
      post 'update_positions' => "horses#update_horse_position", as: :update_position
    end
  end
  resources :cookies
  post 'import_horses_from_sportsinfo' => 'horses#import_horses_from_sportsinfo', as: :import_horses_from_sportsinfo

  resources :tags
  resources :my_lists
  resources :setup_topics
  resources :templates
  resources :custom_fields
  resources :all_horses
  resources :common_horses, only:[:create, :new, :update, :edit]
  resources :products
  resources :user_stable_roles, only: [:edit, :update]
  get :change_stable, controller: :stables, action: :change_stable, as: :change_stable

  resources :password_resets

  namespace :web_hooks do
    post :import_emails, controller: :import_emails, action: :run
    post :subscription_deleted, controller: :subscription_deleted, action: :run



  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do

    namespace :owner, defaults: {format: 'json'} do
      namespace :v1, defaults: {format: 'json'} do
        resources :sessions, only: [:create, :destroy]
        get :autologin, controller: :sessions, action: :autologin
        get :user, controller: :users, action: :show
        post :sign_up, controller: :users, action: :sign_up
        patch :user, controller: :users, action: :update
        post :forgotten_password, controller: :users, action: :forgotten_password
        post :set_user_avatar, controller: :users, action: :set_avatar
        get :push_settings, controller: :users, action: :push_settings
        patch :push_token, controller: :users, action: :update_push_token
        delete :push_token, controller: :users, action: :delete_push_token
        post :cannot_find_horse, controller: :users, action: :cannot_find_horse
        get :terms_conditions, controller: :users, action: :terms_conditions
        get :get_owners_state, controller: :users, action: :get_owners_state

        resources :horses, only: [:index, :show] do
          get :race_info
          get :training
          get :races

          get :medias
        end
        get :all_races, controller: :horses, action: :all_races
        resources :owners_horse do
          collection do
            get :all_stables, controller: :owners_horse, action: :all_stables
            get :owner_latest_activities
            delete :remove_ownership
            get :owner_request_dead
          end
        end
        delete 'owners_horse/:id' => 'owners_horse#destroy'
        put :request_trainer, controller: :owners_horse, action: :request_trainer
        resources :subscriptions, only: [:create] do
          collection do
            post :cancel_subscription
            get :check_subscription
          end
        end
      end
    end

    namespace :external, defaults: {format: 'json'} do
      namespace :v1, defaults: {format: 'json'} do
        post :share_a_horse, controller: :share_a_horses, action: :create
        put :share_a_horse, controller: :share_a_horses, action: :update
        delete :share_a_horse,  controller: :share_a_horses, action: :destroy
      end
    end

    namespace :v4, defaults: {format: 'json'} do
      resources :sessions, only: [:create, :destroy]
      get :autologin, controller: :sessions, action: :autologin
      post :terms_accepted, controller: :users, action: :terms_accepted
      post :set_user_avatar, controller: :users, action: :set_avatar
      get :push_settings, controller: :users, action: :push_settings

      resources :stables do
        resources :tasks, only: [:index, :create, :show]
        get :tasks_with_horses, controller: :tasks
        collection do
          get :get_mto_template, controller: :tasks
        end
        resources :horses, only: :index
        resources :tags, only: :index
        resources :templates, only: :index
        resources :users, only: [:index]
        resources :my_plans, only: :index
        resources :my_lists, only: [:index, :create]
        resources :feedbacks, only: :index
        get 'my_activities' => 'activities#my_activities'
        get 'load_dashboard' => 'my_plans#load_dashboard'
        get 'find_templates' => 'templates#find_templates'
        patch 'read_feedback/:id' => 'feedbacks#read_feedback'
        patch 'read_all_feedbacks/:type' => 'feedbacks#read_all_feedbacks'
      end

      resources :my_lists, only: [:index, :update, :destroy]
      resources :my_plans, only: :index

      resources :horses, only: [:show] do
        get :race_info
        resources :tags, only: :index, action: :horse_tags
        resources :tags, only: :show
        resources :activities, only: :index
        resources :horse_setups, only: :index
        post :set_avatar
      end

      resources :horse_flags, only: [:create, :destroy]

      resources :horse_setups, only: [:update, :show]

      resources :tasks, only: [:update, :destroy] do
        resources :comments, only: [:index, :create]
        resources :task_logs, only: [:index]
        post :complete
        post :add_image
      end

      resources :owners, only: [:index] do
        collection do
          post :accept_reject_request
          post :trainer_remove_owner
        end
      end
      post 'tasks/:task_id/delete_image/:id' => 'tasks#delete_image'
      get 'tasks/:task_id/taggable_users' => 'tasks#taggable_users'

      patch 'tasks', controller: :tasks, action: :patch_multiple
      delete 'tasks', controller: :tasks, action: :destroy_multiple
      post 'forgotten_password' => 'users#forgotten_password', as: :forgotten
      patch 'stables/:stable_id/user' => 'users#update', as: :user
      patch 'user/push_token' => 'users#update_push_token'
      delete 'user/delete_push_token' => 'users#delete_push_token'
      get 'user/get_active_request' => 'users#get_active_request'
    end

    namespace :v3, defaults: {format: 'json'} do
      resources :sessions, only: [:create, :destroy]
      get :autologin, controller: :sessions, action: :autologin
      post :terms_accepted, controller: :users, action: :terms_accepted
      post :set_user_avatar, controller: :users, action: :set_avatar
      get :push_settings, controller: :users, action: :push_settings

      resources :stables do
        resources :tasks, only: [:index, :create]
        get :tasks_with_horses, controller: :tasks
        resources :horses, only: :index
        resources :tags, only: :index
        resources :templates, only: :index
        resources :users, only: [:index]
        resources :my_plans, only: :index
        resources :my_lists, only: [:index, :create]
        resources :notifications, only: :index
        get 'my_activities' => 'activities#my_activities'
        patch 'read_notification/:id' => 'notifications#read_notification'
        patch 'read_all_notifications/:type' => 'notifications#read_all_notifications'
      end

      resources :my_lists, only: [:index, :update, :destroy]
      resources :my_plans, only: :index

      resources :horses, only: [:show] do
        get :race_info
        resources :tags, only: :index, action: :horse_tags
        resources :tags, only: :show
        resources :activities, only: :index
        resources :horse_setups, only: :index
        post :set_avatar
      end

      resources :horse_flags, only: [:create, :destroy]

      resources :horse_setups, only: [:update, :show]

      resources :tasks, only: [:update, :destroy] do
        resources :comments, only: [:index, :create]
        resources :task_logs, only: [:index]
        post :complete
      end

      patch 'tasks', controller: :tasks, action: :patch_multiple
      delete 'tasks', controller: :tasks, action: :destroy_multiple
      post 'forgotten_password' => 'users#forgotten_password', as: :forgotten
      patch 'user' => 'users#update', as: :user
    end

    namespace :v2, defaults: {format: 'json'} do
      resources :sessions, only: [:create, :destroy]
      get :autologin, controller: :sessions, action: :autologin
      post :terms_accepted, controller: :users, action: :terms_accepted

      resources :stables do
        resources :tasks, only: [:index, :create]
        get :tasks_with_horses, controller: :tasks
        resources :horses, only: :index
        resources :tags, only: :index
        resources :templates, only: :index
        resources :users, only: [:index]
        resources :my_plans, only: :index
        resources :my_lists, only: [:index, :create]
        resources :notifications, only: :index
        get 'my_activities' => 'activities#my_activities'
      end

      resources :my_lists, only: [:update, :destroy]

      resources :horses, only: [:show] do
        get :race_info
        resources :tags, only: :index, action: :horse_tags
        resources :tags, only: :show
        resources :activities, only: :index
        resources :horse_setups, only: :index
      end

      resources :horse_flags, only: [:create, :destroy]

      resources :horse_setups, only: [:update, :show]

      resources :tasks, only: [:update, :destroy] do
        resources :comments, only: [:index, :create]
        post :complete
      end

      patch 'tasks', controller: :tasks, action: :patch_multiple
      delete 'tasks', controller: :tasks, action: :destroy_multiple
      post 'forgotten_password' => 'users#forgotten_password', as: :forgotten
    end

    namespace :v1, defaults: {format: 'json'} do
      resources :sessions, only: [:create, :destroy]
      get :autologin, controller: :sessions, action: :autologin

      resources :stables do
        resources :tasks, only: [:index, :create]
        get :tasks_with_horses, controller: :tasks
        resources :horses, only: :index
        resources :tags, only: :index
        resources :templates, only: :index
        resources :users, only: :index
        resources :my_plans, only: :index
        resources :my_lists, only: [:index, :create]
        resources :notifications, only: :index
        get 'my_activities' => 'activities#my_activities'
      end

      resources :my_lists, only: [:update, :destroy]

      resources :horses, only: [:show] do
        get :race_info
        resources :tags, only: :index, action: :horse_tags
        resources :tags, only: :show
        resources :activities, only: :index
        resources :horse_setups, only: :index
      end

      resources :horse_flags, only: [:create, :destroy]

      resources :horse_setups, only: [:update, :show]

      resources :tasks, only: [:update, :destroy] do
        resources :comments, only: [:index, :create]
        post :complete
      end
      patch 'tasks', controller: :tasks, action: :patch_multiple
      delete 'tasks', controller: :tasks, action: :destroy_multiple
      post 'forgotten_password' => 'users#forgotten_password', as: :forgotten
    end
  end
end
