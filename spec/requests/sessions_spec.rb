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

    it "redirects with alert when no auth data is received" do
      # Remove mocked auth so request.env["omniauth.auth"] is nil
      OmniAuth.config.mock_auth[:google_oauth2] = nil
      get "/auth/google_oauth2/callback"
      expect(response).to redirect_to(root_path)
      follow_redirect!
      # In this environment, OmniAuth fallback triggers the rescue path
      expect(response.body).to include("Could not sign in.")
    end

    it "rescues RecordInvalid and shows a generic error" do
      allow(User).to receive(:from_omniauth).and_raise(ActiveRecord::RecordInvalid.new(User.new))
      get "/auth/google_oauth2/callback"
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Could not sign in.")
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

  describe "GET /auth/failure" do
    it "redirects with provided failure message" do
      get "/auth/failure", params: { message: "access_denied" }
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("access_denied")
    end

    it "redirects with default failure message when none provided" do
      get "/auth/failure"
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Authentication failed.")
    end
  end
end
