Rails.application.routes.draw do

  root 'tickets#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :tickets
end
