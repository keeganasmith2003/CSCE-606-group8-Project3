Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV["GOOGLE_OAUTH_CLIENT_ID"],
           ENV["GOOGLE_OAUTH_CLIENT_SECRET"],
           {
             prompt: "select_account",
             access_type: "offline",
             scope: "email,profile"
           }
end
OmniAuth.config.allowed_request_methods = [:get, :post]