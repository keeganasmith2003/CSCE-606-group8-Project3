require "rails_helper"

RSpec.describe "Profile page", type: :request do
  def doc
    Nokogiri::HTML(response.body)
  end

  it "shows the current user's name and email after signing in" do
    user = User.create!(provider: "google_oauth2", uid: "u1", email: "me@example.com", name: "Me", role: :user)
    sign_in(user)

    get profile_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Me")
    expect(response.body).to include("me@example.com")
  end
end
