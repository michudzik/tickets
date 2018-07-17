Rails.application.routes.draw do
  root 'home#home'
  devise_for :users
  get '/user_dashboard', to: 'users#show'
  resources :users, only: [:index, :update] do
    member do
      put :deactivate_account
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
