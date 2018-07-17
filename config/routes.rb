Rails.application.routes.draw do
  root 'home#home'
  devise_for :users
  resources :users, only: :show do 
  	resources :comments, only: [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
