Rails.application.routes.draw do
  # Public timeline (Twitter-like UI)
  root "thoughts#index"
  resources :thoughts, only: [ :index, :show ]

  # Static pages
  get "about", to: "pages#about"
  get "colophon", to: "pages#colophon"

  # JSON API (read = public, write = token auth)
  namespace :api do
    resources :thoughts, only: [ :index, :show, :create, :update, :destroy ]
    get "tags", to: "tags#index"
  end

  # Admin interface (session auth)
  namespace :admin do
    resources :thoughts
    resource :session, only: [ :new, :create, :destroy ]
    post "regenerate_token", to: "sessions#regenerate_token"
    root "thoughts#index"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
