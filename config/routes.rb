Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: 'invitations' }
  resources :users

  require 'sidekiq/web'
  authenticate :user, ->(user) { user.has_role?(:admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get "up" => "rails/health#show", as: :rails_health_check

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
        patch :update_status
        post :add_status
      end
      resources :issues
      resources :comments
    end
  end

  resources :product do
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
  resources :status

end
