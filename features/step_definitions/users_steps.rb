# ---------- Seed helpers ----------

Given("there is a user in the database with email {string} and role {string} named {string}") do |email, role, name|
  User.create!(
    provider: "seed",
    uid: SecureRandom.uuid,
    email: email,
    role: role,
    name: name
  )
end

Given("there is a user in the database with email {string} and role {string}") do |email, role|
  User.create!(
    provider: "seed",
    uid: SecureRandom.uuid,
    email: email,
    role: role
  )
end

Given("there are users:") do |table|
  table.hashes.each do |h|
    User.find_or_create_by!(email: h.fetch("email").downcase) do |u|
      u.provider = "seed"
      u.uid = SecureRandom.uuid
      u.role = h.fetch("role")
      u.name = h["name"]
    end
  end
end

# ---------- Login via OmniAuth ----------

Given("I log in with Google as uid {string}, email {string}, name {string}") do |uid, email, name|
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: "google_oauth2",
    uid: uid,
    info: { email: email, name: name }
  )
  visit "/login"  # SessionsController#new -> redirects to /auth/google_oauth2
end



# ---------- Navigation helpers ----------

When("I visit the users index") do
  visit users_path
end

When("I visit the new user page") do
  visit new_user_path
end

When("I visit the show page for user with email {string}") do |email|
  user = User.find_by!(email: email.downcase)
  visit user_path(user)
end

When("I visit the edit page for user with email {string}") do |email|
  user = User.find_by!(email: email.downcase)
  visit edit_user_path(user)
end

# ---------- UI interaction helpers ----------

Then("I should not see the {string} button") do |label|
  expect(page).to have_no_link(label)
  expect(page).to have_no_button(label)
end

When("I delete the user with email {string}") do |email|
  user = User.find_by!(email: email.downcase)
  within("tr#user_#{user.id}") do
    if Capybara.current_driver == Capybara.javascript_driver
      accept_confirm { click_button "Delete" }
    else
      click_button "Delete"
    end
  end
end

# ---------- Authorization assertion ----------

Then("I should be denied access") do
  denied = defined?(@authorization_error) && @authorization_error ||
           page.has_content?("Not authorized") ||
           page.has_content?("You are not authorized") ||
           (page.respond_to?(:status_code) && [ 401, 403 ].include?(page.status_code))
  expect(denied).to be(true), "Expected an authorization failure (flash or 401/403), but didn't detect one"
end
