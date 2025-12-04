module LoginHelper
  def login_with_google
    OmniAuth.config.test_mode = true
    # Silence the GET-warning from OmniAuth in test runs
    OmniAuth.config.silence_get_warning = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '12345',
      info: {
        name: 'Test User',
        email: 'testuser@example.com'
      }
    )

    # This matches your real route
    visit '/auth/google_oauth2'
  end
  def login_as_user(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.silence_get_warning = true

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: user.uid,
      info: {
        name: user.name,
        email: user.email,
        image: user.image_url
      },
      credentials: {
        token: 'mock_token',
        refresh_token: 'mock_refresh_token',
        expires_at: Time.now + 1.week
      }
    )

    visit '/auth/google_oauth2'
  end
end


World(LoginHelper)
