require "rails_helper"

RSpec.describe "Sessions (OmniAuth)", type: :request do
  before { mock_google_auth } # sets OmniAuth.config.mock_auth[:google_oauth2]

  describe "GET /login" do
    it "redirects to provider" do
      get login_path
      expect(response).to have_http_status(:redirect)
      # Typically redirects to /auth/google_oauth2
      expect(response).to redirect_to(%r{/auth/google_oauth2})
    end
  end

  describe "GET/POST /auth/:provider/callback" do
    it "creates/updates user and sets session" do
      # Simulate the callback route (Rails usually receives GET or POST)
      get "/auth/google_oauth2/callback"
      follow_redirect!

      expect(session[:user_id]).to be_present
      expect(response.body).to include("Signed in").or include("Welcome")
      expect(User.count).to eq(1)
      expect(User.first.email).to eq("user@example.com")
    end

    it "handles failure" do
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
      get "/auth/google_oauth2/callback"
      follow_redirect!
      expect(response.body).to include("Could not sign in").or include("Authentication failed")
      expect(session[:user_id]).to be_nil
    end
  end

  describe "DELETE /logout" do
    it "clears the session" do
      # sign in first
      get "/auth/google_oauth2/callback"
      expect(session[:user_id]).to be_present

      delete logout_path
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end
end
