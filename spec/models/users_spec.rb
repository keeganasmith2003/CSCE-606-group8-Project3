require "rails_helper"

RSpec.describe User, type: :model do
  describe "enums" do
    it { is_expected.to define_enum_for(:role).with_values(user: 0, sysadmin: 1, staff: 2).backed_by_column_of_type(:integer) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value("a@b.com").for(:email) }
    it { is_expected.not_to allow_value("invalid").for(:email) }

    it "downcases email before validation" do
      u = build(:user, email: "MiXeD@ExAmPle.COM")
      u.validate
      expect(u.email).to eq("mixed@example.com")
    end

    it "validates email uniqueness case-insensitively" do
      create(:user, email: "dup@example.com")
      dup = build(:user, email: "DUP@example.com", uid: "other-uid")
      expect(dup).not_to be_valid
      expect(dup.errors[:email]).to be_present
    end
  end

  describe ".from_omniauth" do
    let(:auth) do
      {
        "provider" => "google_oauth2",
        "uid" => "abc123",
        "info" => { "email" => "u@example.com", "name" => "Alice", "image" => "https://img" },
        "credentials" => { "token" => "tok", "refresh_token" => "ref", "expires_at" => 1.hour.from_now.to_i }
      }
    end

    it "creates a new user on first sign-in" do
      user = described_class.from_omniauth(auth)
      expect(user).to be_persisted
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("abc123")
      expect(user.email).to eq("u@example.com")
      expect(user.name).to eq("Alice")
      expect(user.image_url).to eq("https://img")
      expect(user.access_token).to eq("tok")
      expect(user.refresh_token).to eq("ref")
      expect(user.access_token_expires_at).to be_within(5.seconds).of(Time.at(auth["credentials"]["expires_at"]))
    end

    it "updates an existing user on subsequent sign-ins" do
      existing = create(:user, provider: "google_oauth2", uid: "abc123", email: "old@example.com")
      user = described_class.from_omniauth(auth)
      expect(user.id).to eq(existing.id)
      expect(user.email).to eq("u@example.com")
      expect(user.name).to eq("Alice")
    end

    it "raises if provider/uid missing" do
      expect { described_class.from_omniauth({}) }.to raise_error(ArgumentError)
    end
  end

  describe "#display_name" do
    it "returns name if present" do
      u = build(:user, name: "Bob", email: "bob@example.com")
      expect(u.display_name).to eq("Bob")
    end

    it "falls back to email local part" do
      u = build(:user, name: nil, email: "charlie@example.com")
      expect(u.display_name).to eq("charlie")
    end
  end
end
