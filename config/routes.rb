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
  # Dashboard routes
  # /dashboard as the Kanban-style board (tickets#board)
  get "/dashboard", to: "tickets#board", as: :dashboard

  # Summary (metrics) route for personal metrics
  get "/summary", to: "metrics#user_metrics", as: :summary

  # Admin metrics dashboard
  get "/metrics/admin", to: "metrics#admin_dashboard", as: :admin_dashboard

  # Personal dashboard route
  get "/personal_dashboard", to: "tickets#dashboard", as: :personal_dashboard

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
