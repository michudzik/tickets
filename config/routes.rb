Rails.application.routes.draw do
  root 'home#home'
  devise_for :users
  resources :registrations, only: [:edit, :update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
