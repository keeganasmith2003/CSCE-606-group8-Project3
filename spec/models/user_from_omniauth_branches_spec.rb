require "rails_helper"

RSpec.describe User, ".from_omniauth branches" do
  def auth_hash(overrides = {})
    base_time = Time.current + 1.hour
    {
      "provider" => "google_oauth2",
      "uid" => "abc123",
      "info" => { "email" => "u@example.com", "name" => "Alice", "image" => "https://img" },
      "credentials" => { "token" => "tok", "refresh_token" => "ref", "expires_at" => base_time.iso8601 }
    }.deep_merge(overrides)
  end

  it "coerces expires_at when provided as String" do
    t = (Time.current + 90.minutes).change(usec: 0)
    auth = auth_hash("credentials" => { "expires_at" => t.iso8601 })
    user = described_class.from_omniauth(auth)
    expect(user.access_token_expires_at).to be_within(2.seconds).of(Time.parse(t.iso8601))
  end

  it "accepts expires_at when provided as Time" do
    t = Time.current + 30.minutes
    auth = auth_hash("credentials" => { "expires_at" => t })
    user = described_class.from_omniauth(auth)
    expect(user.access_token_expires_at).to be_within(2.seconds).of(t)
  end

  it "updates same-email user even when uid changes" do
    existing = create(:user, provider: "google_oauth2", uid: "old-uid", email: "u@example.com", name: "Old")
    auth = auth_hash("uid" => "new-uid")
    user = described_class.from_omniauth(auth)
    expect(user.id).to eq(existing.id)
    expect(user.uid).to eq("new-uid")
    expect(user.name).to eq("Alice")
  end
end
