Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create index] do
        collection do
          post 'login-as-visitor'
          post 'login-via-gaas-token'
          get 'me-via-gaas-token'
        end
      end
      get 'me', to: 'users#show'
      resource :preferences, only: %i[show update]

      resources :rooms, only: %i[index show create] do
        member do
          post 'close', to: 'rooms#destroy'
          post 'game', to: 'games#create'
          delete 'game', to: 'games#destroy'
          post 'game/split', to: 'games#split'
          post 'game/play-unit', to: 'games#play'
        end
      end
      resources :games, only: %i[show destroy create] do
        member do
          post 'end-game-via-gaas-token'

          post 'init-map-automatically', to: 'games#init_map_automatically'
          post 'reset-game', to: 'games#reset_game'

          post 'place-stack-automatically', to: 'games#random_place_stack'
          post 'place-stack', to: 'games#place_stack'

          post 'split-stack-automatically', to: 'games#random_split_stack'
          post 'split-stack', to: 'games#split_stack'
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
