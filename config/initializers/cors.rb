# Allow the swm.cc homepage to fetch public thoughts client-side
# (read-only: the write endpoints stay same-origin + token-authed).
# See https://github.com/swmcc/thoughts/issues/36

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://swm.cc"
    resource "/api/*", headers: :any, methods: [ :get ]
  end
end
