require "rails_helper"

RSpec.describe User, ".from_omniauth edge cases" do
  it "raises when info is missing and no email present" do
    auth = { "provider" => "google_oauth2", "uid" => "no-email", "info" => {} }
    expect { described_class.from_omniauth(auth) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "handles missing credentials by not setting tokens" do
    auth = {
      "provider" => "google_oauth2",
      "uid" => "tok-less",
      "info" => { "email" => "tokless@example.com", "name" => "Tok Less" }
      # no credentials key
    }
    user = described_class.from_omniauth(auth)
    expect(user.access_token).to be_nil
    expect(user.refresh_token).to be_nil
    expect(user.access_token_expires_at).to be_nil
  end
end
