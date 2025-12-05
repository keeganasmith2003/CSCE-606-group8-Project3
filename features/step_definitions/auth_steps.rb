# frozen_string_literal: true

require "omniauth"

Given("OmniAuth is in test mode") do
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google_oauth2] = nil
  OmniAuth.config.on_failure = Proc.new { |env|
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  }
end

Given("the Google mock returns uid {string}, email {string}, name {string}") do |uid, email, name|
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: "google_oauth2",
    uid: uid,
    info: { email: email, name: name },
    credentials: {
      token: "t-#{uid}",
      refresh_token: "rt-#{uid}",
      expires_at: Time.now + 1.week
    }
  )
end

Given("OmniAuth is set to fail with message {string}") do |message|
  OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::FailureEndpoint.new(
    "omniauth.error.type" => message
  )
  # The canonical way to simulate failure for most stacks:
  OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  allow_any_instance_of(SessionsController).to receive(:failure).and_call_original
end

When("I click {string}") do |label|
  click_link_or_button label
end

Given("I am logged in as {string}") do |name|
  user = User.find_by(name: name)
  raise "User #{name} not found" unless user
  login_as_user(user)
end
Then("the app should have exactly {int} user with email {string}") do |count, email|
  expect(User.where(email: email.downcase).count).to eq(count)
end

Then("that user should have provider {string} and uid {string}") do |provider, uid|
  user = User.find_by(provider: provider, uid: uid)
  expect(user).to be_present
end

Given("there is a user in the database with email {string} and role {string}") do |email, role|
  User.create!(
    provider: "seed",
    uid: SecureRandom.uuid,
    email: email,
    role: role
  )
end

Given("there is a sysadmin in the database with email {string} named {string}") do |email, name|
  User.create!(
    provider: "seed",
    uid: SecureRandom.uuid,
    email: email,
    name: name,
    role: :sysadmin
  )
end
