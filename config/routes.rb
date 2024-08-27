Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: 'invitations' }
  resources :users

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
        post :assign_user
        delete :unassign_user
      end
      resources :issues
    end
  end

end
