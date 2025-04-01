Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: 'invitations' }
  resources :users do
    collection do
      get :search
    end
    member do
      patch :status
    end
  end

  require 'sidekiq/web'
  authenticate :user, ->(user) { user.has_role?(:admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get "up" => "rails/health#show", as: :rails_health_check

  get 'cease_fire_report', to: 'data_center#cease_fire_report', as: 'cease_fire_report'
  get 'breach_report', to: 'data_center#breach_report', as: 'breach_report'
  get 'user_report', to: 'data_center#user_report', as: 'user_report'
  get 'project_report', to: 'data_center#project_report', as: 'project_report'
  get 'orm_report', to: 'data_center#orm_report', as: 'orm_report'
  get 'orm_team_report', to: 'data_center#orm_team_report', as: 'orm_team_report'

  get 'sod_report', to: 'data_center#sod_report', as: 'sod_report'
  get 'assigned_tickets', to: 'data_center#assigned_tickets', as: 'assigned_tickets'
  get 'user_report_view', to: 'data_center#user_report_view', as: 'user_report_view'
  get 'cbk_groupware_report', to: 'data_center#cbk_groupware_report', as: 'cbk_groupware_report'

  get 'dashboard', to: 'dashboards#index'
  get 'dashboards/fetch_stats', to: 'dashboards#fetch_stats'
  get 'dashboards/tickets', to: 'dashboards#tickets'

  root "home#index"
  get "home/index"

  resources :project do
    member do
      post :assign_user
      delete :unassign_user
      post :add_team
      delete :remove_team
    end
    resources :tickets do
      collection do
        get 'all_tickets'
        get 'index_home'
      end
      member do
        post :assign_tag
        delete :unassign_tag
        post :add_status
        patch :update_due_date
        patch :update_priority
        patch :update_issue_type
      end
      resources :issues
      resources :comments
      resources :ratings, only: :create
    end
  end

  resources :product do
    member do
      post :add_user
      delete :remove_user
    end
    resources :bugs do
     member do
       post :add_bug
       delete :remove_bug
       post :bug_status
     end
    end
    resources :boards do
      resources :tasks do
        member do
          post :add_task
          delete :remove_task
          post :add_state
          delete :remove_state
        end
      end
    end
  end

  resources :projects do
    resources :groupwares, only: :index
  end
  resources :product do
    resources :groupwares do
      collection do
        get 'show_product_groupware', to: 'groupwares#show_product_groupware'
      end
      member do
        get 'show_index', to: 'scripts#show_index'
      end
    end
  end

  resources :software do
    resources :groupwares do
      resources :scripts

    end # Nested groupwares if needed in the context of software
  end

  resources :tasks do
    resources :messages, only: [:index, :create]
  end

  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end
  end

  resources :groupwares # Independent route for AJAX requests

  resources :client
  resources :status
  resources :team
  resources :location
end