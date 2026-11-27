Rails.application.routes.draw do
  # Public timeline (Twitter-like UI)
  root "thoughts#index"
  resources :thoughts, only: [ :index, :show ]

  # Static pages
  get "about", to: "pages#about"
  get "colophon", to: "pages#colophon"

  # JSON API (read = public, write = token auth)
  namespace :api do
    resources :thoughts, only: [ :index, :show, :create, :update, :destroy ] do
      member { get :thread }
    end
    get "tags", to: "tags#index"
  end

  # Admin interface (session auth)
  namespace :admin do
    resources :thoughts
    resource :session, only: [ :new, :create, :destroy ]
    post "regenerate_token", to: "sessions#regenerate_token"
    root "thoughts#index"
  end

  # MCP connector for Claude (OAuth-protected; see Oauth:: controllers)
  post "mcp", to: "mcp#create"
  match "mcp", to: "mcp#unsupported", via: [ :get, :delete ]

  get ".well-known/oauth-protected-resource(/mcp)", to: "oauth/metadata#protected_resource"
  get ".well-known/oauth-authorization-server", to: "oauth/metadata#authorization_server"
  namespace :oauth do
    post "register", to: "registrations#create"
    get "authorize", to: "authorizations#new"
    post "authorize", to: "authorizations#create"
    post "token", to: "tokens#create"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
