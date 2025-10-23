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
end

World(LoginHelper)
