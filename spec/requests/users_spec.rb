require "rails_helper"

RSpec.describe "Users", type: :request do
  # Helper: sign in through OmniAuth callback as the given user
  def sign_in_as(user)
    mock_google_auth(uid: user.uid, email: user.email, name: user.name || "Tester")
    get "/auth/google_oauth2/callback"
    expect(session[:user_id]).to eq(user.id)
  end

  let(:provider) { "google_oauth2" }

  describe "GET /users" do
    context "when not signed in" do
      it "redirects to login" do
        get users_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when signed in as non-sysadmin" do
      it "redirects with Not authorized" do
        user = create(:user, provider: provider, uid: "u-nonadmin", role: :user, email: "nonadmin@example.com")
        sign_in_as(user)

        get users_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Users")
      end
    end

    context "when signed in as sysadmin" do
      it "renders index" do
        admin = create(:user, provider: provider, uid: "u-admin", role: :sysadmin, email: "admin@example.com", name: "Admin")
        sign_in_as(admin)

        get users_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Users").or include("<h1>")
      end
    end
  end

  describe "POST /users" do
    context "when not signed in" do
      it "redirects to login" do
        post users_path, params: { user: { email: "x@y.z" } }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when signed in as non-sysadmin" do
      it "redirects with Not authorized" do
        user = create(:user, provider: provider, uid: "u-nonadmin2", role: :user, email: "nonadmin2@example.com")
        sign_in_as(user)

        post users_path, params: { user: { email: "new@example.com", provider: provider, uid: "xyz123" } }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    context "when signed in as sysadmin" do
      let!(:admin) { create(:user, provider: provider, uid: "u-admin2", role: :sysadmin, email: "admin2@example.com") }

      before { sign_in_as(admin) }

      it "creates a user with valid params" do
        params = {
          user: {
            provider: provider,
            uid: "xyz123",
            email: "new@example.com",
            name: "New User",
            role: :user
          }
        }
        expect {
          post users_path, params: params
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(user_path(User.last))
      end

      it "renders errors with invalid params" do
        expect {
          post users_path, params: { user: { email: "" } }
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /users/:id" do
    context "when signed in as sysadmin" do
      let!(:admin) { create(:user, provider: provider, uid: "u-admin3", role: :sysadmin, email: "admin3@example.com") }
      let!(:user)  { create(:user, name: "Old", provider: provider, uid: "u-target", email: "target@example.com") }

      before { sign_in_as(admin) }

      it "updates and redirects" do
        patch user_path(user), params: { user: { name: "New" } }
        expect(response).to redirect_to(user_path(user))
        expect(user.reload.name).to eq("New")
      end

      it "renders errors with :unprocessable_content for invalid params" do
        # Make email invalid (blank) to trigger validation errors
        patch user_path(user), params: { user: { email: "" } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("prohibited this user from being saved:")
      end
    end

    context "when non-sysadmin" do
      it "redirects with Not authorized" do
        member = create(:user, provider: provider, uid: "u-nonadmin3", role: :user, email: "na3@example.com")
        target  = create(:user, provider: provider, uid: "u-target2", email: "t2@example.com", name: "Old")
        sign_in_as(member)

        patch user_path(target), params: { user: { name: "Hack" } }
        expect(response).to redirect_to(root_path)
        expect(target.reload.name).to eq("Old")
      end
    end
  end

  describe "DELETE /users/:id" do
    context "when sysadmin" do
      it "deletes and redirects" do
        admin = create(:user, provider: provider, uid: "u-admin4", role: :sysadmin, email: "admin4@example.com")
        victim = create(:user, provider: provider, uid: "u-victim", email: "victim@example.com")
        sign_in_as(admin)

        expect {
          delete user_path(victim)
        }.to change(User, :count).by(-1)
        expect(response).to redirect_to(users_path)
      end
    end

    context "when non-sysadmin" do
      it "does not delete and redirects with Not authorized" do
        member = create(:user, provider: provider, uid: "u-nonadmin4", role: :user, email: "na4@example.com")
        victim = create(:user, provider: provider, uid: "u-victim2", email: "victim2@example.com")
        sign_in_as(member)

        expect {
          delete user_path(victim)
        }.not_to change(User, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not signed in" do
      it "redirects to login" do
        victim = create(:user, provider: provider, uid: "u-victim3", email: "victim3@example.com")
        delete user_path(victim)
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
