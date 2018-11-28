Rails.application.routes.draw do
  mount ActionCable.server, at: '/cable'
  root 'home#home'
  devise_for :users, controllers: {  registrations: 'registrations', sessions: 'sessions' }
  get '/new_ticket', to: 'tickets#new'
  get '/show_tickets', to: 'tickets#index'
  get '/user_dashboard', to: 'users#show'
  get '/tickets/:id',   to: 'tickets#show', as: :ticket
  get '/search', to: 'tickets#search', as: :search_tickets
  resources :comments, only: :create
  resources :users, only: [:index, :update] do
    resources :tickets, except: [:new, :index, :show, :update] do
      member do 
        put :close
      end
    end
    member do
      put :deactivate_account
      put :activate_account
    end
  end

  namespace :api, path: '', defaults: { format: :json } do
    namespace :v1 do
      get '/user_dashboard', to: 'users#show'
      resources :users, only: [:index, :update] do
        member do
          put :deactivate_account
          put :activate_account
        end
      end

      get '/search', to: 'tickets#search', as: :search_tickets
      resources :tickets, only: [:index, :show, :create] do
        member do 
          put :close
        end
      end

      resources :comments, only: :create
      resources :roles, only: :index
      resources :departments, only: :index
    end
  end
end
