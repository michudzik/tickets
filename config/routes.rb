Rails.application.routes.draw do
  #root 'tickets#index'
  root 'home#home'
  devise_for :users
  get '/user_dashboard', to: 'users#show'
  resources :users, only: [:index, :update] do
    resources :comments, only: [:create, :destroy]
    member do
      put :deactivate_account
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :tickets
end
