require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  describe "create without auth" do
    it "redirects to root with alert when omniauth.auth is missing" do
      request.env["omniauth.auth"] = nil
      get :create, params: { provider: "google_oauth2" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("No auth data received.")
    end
  end
end
