Rails.application.routes.draw do
  root "home#index"

  resources :users
  get "/profile", to: "users#profile", as: :profile
  resources :tickets do
    collection do
      get :mine
      get :board
    end
    member do
      patch :assign
      patch :approve
      patch :reject
      patch :close
    end
    resources :comments, only: :create
  end
  # dashboard summarizing tickets assigned to the current user
  get "/dashboard", to: "tickets#dashboard", as: :dashboard
  resources :teams do
    resources :team_memberships, only: [ :create, :destroy ]
  end
  get    "/login",  to: "sessions#new"
  delete "/logout", to: "sessions#destroy"
  match  "/auth/:provider/callback", to: "sessions#create", via: [ :get, :post ]
  get    "/auth/failure", to: "sessions#failure"

  if Rails.env.development? || Rails.env.test?
    get "/dev_login/:uid",       to: "dev_login#by_uid", constraints: { uid: /[A-Za-z0-9_\-]+/ }, format: false
  end
end
