require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /users" do
    it "renders index" do
      get users_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Users").or include("<h1>")
    end
  end

  describe "POST /users" do
    it "creates a user with valid params" do
      params = {
        user: {
          provider: "google_oauth2",
          uid: "xyz123",
          email: "new@example.com",
          name: "New User",
          role: 0
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
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /users/:id" do
    let!(:user) { create(:user, name: "Old") }

    it "updates and redirects" do
      patch user_path(user), params: { user: { name: "New" } }
      expect(response).to redirect_to(user_path(user))
      expect(user.reload.name).to eq("New")
    end
  end

  describe "DELETE /users/:id" do
    it "deletes and redirects" do
      user = create(:user)
      expect {
        delete user_path(user)
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(users_path)
    end
  end
end
