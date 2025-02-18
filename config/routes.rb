Rails.application.routes.draw do
  get 'dashboard', to: 'dashboards#index'
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
      member do
        post :assign_tag
        delete :unassign_tag
        post :add_status
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

  resources :software do
    resources :groupwares # Nested groupwares if needed in the context of software
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
end