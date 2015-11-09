Rails.application.routes.draw do

  get 'errors/file_not_found'

  get 'errors/unprocessable'

  get 'errors/internal_server_error'

  root "home#index"

  get "/browse", to: "loan_requests#index"

  get "/portfolio", to: "borrower_portfolio#show"

  resources :payment, only: [:update]

  resources :loan_requests

  get "/cart", to: "cart#index"
  post "/cart", to: "cart#create"
  delete "/cart", to: "cart#delete"
  put "/cart", to: "cart#update"

  resources :orders, only: [:create, :index, :show, :update]

  get "/login", to: "sessions#new", :as => "login"
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy"
  delete "/logout", to: "sessions#destroy"

  resources :admin

  resources :lenders

  resources :borrowers

  resources :users, only: [:show]

  match "/404", to: "errors#file_not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "/422", to: "errors#unprocessable", via: :all
end
