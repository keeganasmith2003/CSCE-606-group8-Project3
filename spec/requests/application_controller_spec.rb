require "rails_helper"

RSpec.describe "ApplicationController behaviors", type: :request do
  describe "require_login HTML branch" do
    it "stores return_to and redirects to login for HTML GET" do
      get users_path # unauthenticated, guarded by require_login
      expect(response).to redirect_to(login_path)
      expect(session[:return_to]).to eq(users_path)
    end
  end

  describe "require_sysadmin" do
    it "redirects non-sysadmin to root with alert when accessing users#new" do
      member = create(:user, role: :user)
      mock_google_auth(uid: member.uid, email: member.email, name: member.name || "Tester")
      get "/auth/google_oauth2/callback"
      expect(session[:user_id]).to eq(member.id)

      get new_user_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Not authorized.")
    end
  end
end
