Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: 'invitations' }
  resources :users

  require 'sidekiq/web'
  authenticate :user, ->(user) { user.has_role?(:admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"

  resources :project do
    member do
      post :assign_user
      delete :unassign_user
    end
    resources :tickets do
      member do
        post :assign_tag
        delete :unassign_tag
        post :update_status
      end
      resources :issues
    end
  end

  resources :product do
    resources :documents, only: [:create, :destroy]

    member do
      post :add_user
      delete :remove_user
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

  resources :software
  resources :client




end
