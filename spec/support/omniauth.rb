require "omniauth"

module OmniauthHelpers
  def mock_google_auth(
    uid: "12345",
    email: "user@example.com",
    name: "Test User",
    image: "https://example.com/img.png",
    token: "access-token",
    refresh_token: "refresh-token",
    expires_at: 2.hours.from_now.to_i
  )
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email, name: name, image: image },
      credentials: { token: token, refresh_token: refresh_token, expires_at: expires_at }
    )
  end
end

RSpec.configure do |config|
  # make it available to request specs (and you can add :system, :feature, etc.)
  config.include OmniauthHelpers, type: :request

  # Helper method for signing in users in request specs
  config.include Module.new {
    def sign_in(user)
      mock_google_auth(uid: user.uid, email: user.email, name: user.name || "Tester")
      get "/auth/google_oauth2/callback"
      expect(session[:user_id]).to eq(user.id)
    end
  }, type: :request
end
