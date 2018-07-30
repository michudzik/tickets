Rails.application.routes.draw do
  
  root 'home#home'
  devise_for :users, skip: :registrations, controllers: {  registrations: "registrations" }
  devise_scope :user do
    resource :registration,
      only: [:new, :create, :edit, :update],
      path: 'users',
      path_names: { new: 'sign_up' },
      controller: 'devise/registrations',
      as: :user_registration do
        get :cancel
      end
  end
  get '/new_ticket', to: 'tickets#new'
  get '/show_tickets', to: 'tickets#index'
  get '/user_dashboard', to: 'users#show'
  get '/users_locked', to: 'users#locked'
  get '/users_unlocked', to: 'users#unlocked'
  get '/tickets/:id',   to: 'tickets#show', as: :ticket
  resources :comments, only: :create
  resources :users, only: [:index, :update] do
    resources :tickets, except: [:new, :index, :show]
      member do
        put :deactivate_account
        put :activate_account
      end
    end
end