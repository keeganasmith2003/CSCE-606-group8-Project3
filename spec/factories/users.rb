FactoryBot.define do
  factory :user do
    provider { "google_oauth2" }
    uid      { SecureRandom.hex(8) }
    email    { "user#{SecureRandom.hex(3)}@example.com" }
    name     { "Test User" }
    image_url { "https://example.com/a.png" }
    role { :user }
  end
end
