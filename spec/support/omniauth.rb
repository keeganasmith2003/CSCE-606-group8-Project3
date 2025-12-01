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
  config.include OmniauthHelpers, type: :request
  config.include OmniauthHelpers, type: :system

  # Helper method for signing in users in request specs
  request_sign_in_helper = Module.new do
    def sign_in(user)
      mock_google_auth(uid: user.uid, email: user.email, name: user.name || "Tester")
      get "/auth/google_oauth2/callback"
      expect(session[:user_id]).to eq(user.id)
    end
  end

  system_sign_in_helper = Module.new do
    def sign_in(user)
      mock_google_auth(uid: user.uid, email: user.email, name: user.name || "Tester")
      visit "/auth/google_oauth2/callback"
  # After sign-in, the personal dashboard is the landing page for authenticated users
  expect(page).to have_current_path(personal_dashboard_path)
    end
  end

  config.include request_sign_in_helper, type: :request
  config.include system_sign_in_helper, type: :system
end
