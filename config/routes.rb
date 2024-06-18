Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      # resources :users, only: %i[create show]
      get 'me', to: 'users#show'
      get 'users', to: 'users#index'
      post 'users', to: 'users#create'

      post 'rooms/:id/close', to: 'rooms#destroy'
      put 'rooms/:id', to: 'rooms#join'
      delete 'rooms/:id', to: 'rooms#leave'
      resources :rooms, only: %i[index show create] do
        member do
          get 'game', to: 'games#show'
          post 'game', to: 'games#create'
          delete 'game', to: 'games#destroy'
          post 'game/split', to: 'games#split'
          post 'game/play-unit', to: 'games#play'
        end
      end
    end
  end

  resources :games
  resources :rooms do
    member do
      put :join
      delete :leave
      post :play
    end
  end
  get 'home/index'
  resources :visitors
  get '/login', to: 'sessions#new', as: 'new_user_session'
  post '/login', to: 'sessions#create', as: 'user_session'
  delete '/logout', to: 'sessions#destroy', as: 'destroy_user_session'

  root 'home#index'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
end
