require "omniauth"
OmniAuth.config.test_mode = true

def mock_google_auth(
  uid: "12345",
  email: "user@example.com",
  name: "Test User",
  image: "https://example.com/img.png",
  token: "access-token",
  refresh_token: "refresh-token",
  expires_at: 2.hours.from_now.to_i
)
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: "google_oauth2",
    uid: uid,
    info: { email: email, name: name, image: image },
    credentials: { token: token, refresh_token: refresh_token, expires_at: expires_at }
  )
end