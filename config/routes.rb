Rails.application.routes.draw do
  root "home#index"

  resources :users
  get    "/login",  to: "sessions#new"
  delete "/logout", to: "sessions#destroy"
  match  "/auth/:provider/callback", to: "sessions#create", via: [:get, :post]
  get    "/auth/failure", to: "sessions#failure"
end