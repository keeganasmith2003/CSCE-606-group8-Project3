Rails.application.routes.draw do
  root "home#index"

  resources :users
  resources :tickets do
    member do
      patch :assign
      patch :approve
      patch :reject
      patch :close
    end
    resources :comments, only: :create
  end
  resources :teams do
    resources :team_memberships, only: [ :create, :destroy ]
  end
  get    "/login",  to: "sessions#new"
  delete "/logout", to: "sessions#destroy"
  match  "/auth/:provider/callback", to: "sessions#create", via: [ :get, :post ]
  get    "/auth/failure", to: "sessions#failure"

  # Dev-only quick-login helpers (choose who you want to be)
  if Rails.env.development? || Rails.env.test?
    get "/dev_login/:uid",       to: "dev_login#by_uid", constraints: { uid: /[A-Za-z0-9_\-]+/ }, format: false
  end
end
