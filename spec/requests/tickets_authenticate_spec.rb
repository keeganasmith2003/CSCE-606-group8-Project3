require "rails_helper"

RSpec.describe "Tickets authenticate_user! guard", type: :request do
  it "redirects unauthenticated HTML to login with alert" do
    get tickets_path
    expect(response).to redirect_to(login_path)
    expect(flash[:alert]).to eq("Please sign in.")
  end
end
