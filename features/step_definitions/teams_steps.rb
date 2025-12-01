def create_user!(name:, email:, role:)
  User.create!(
    provider: "google_oauth2",
    uid: "#{role}-#{email}",
    email: email,
    role: role,
    name: name
  )
end

def ensure_omniauth_mock_for(user)
  OmniAuth.config.test_mode = true
  OmniAuth.config.silence_get_warning = true
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: "google_oauth2",
    uid:      user.uid.presence || "cuke-#{user.email}",
    info:     { name: user.name || user.email.split("@").first, email: user.email },
    credentials: {
      token: "mock_token",
      refresh_token: "mock_refresh_token",
      expires_at: (Time.now + 1.week).to_i
    }
  )
end

Given('a staff user {string} exists with email {string}') do |name, email|
  create_user!(name: name, email: email, role: :staff)
end

Given('a requester {string} exists with email {string}') do |name, email|
  create_user!(name: name, email: email, role: :user)
end

Given('a team {string} exists with member {string}') do |team_name, member_name|
  team = Team.find_or_create_by!(name: team_name)
  user = User.find_by!(name: member_name)
  TeamMembership.find_or_create_by!(team: team, user: user)
end

Given('a sysadmin exists with email {string}') do |email|
  name = email.split("@").first.capitalize
  create_user!(name: name, email: email, role: :sysadmin)
end

Given('a staff user exists with email {string}') do |email|
  name = email.split("@").first.capitalize
  create_user!(name: name, email: email, role: :staff)
end

Given('a team {string} exists') do |name|
  Team.find_or_create_by!(name: name)
end

Given('{string} is a member of team {string}') do |email, team_name|
  user = User.find_by!(email: email)
  team = Team.find_by!(name: team_name)
  TeamMembership.find_or_create_by!(team: team, user: user)
end

# ---------- Auth / navigation ----------

When('I login as {string}') do |email|
  user = User.find_by!(email: email)
  ensure_omniauth_mock_for(user)
  visit "/auth/google_oauth2/callback"
  expect(page).to have_current_path(personal_dashboard_path)
end


When('I visit the home page') do
  visit root_path
end

When('I visit the teams index') do
  visit teams_path
end

# ---------- Navbar link assertions ----------

Then('I should see a link {string} pointing to the teams index') do |text|
  expect(page).to have_link(text, href: teams_path)
end

Then('I should see a link {string} pointing to that team page') do |team_name|
  team = Team.find_by!(name: team_name)
  expect(page).to have_link(team_name, href: team_path(team))
end

# ---------- Ticket assignment UI interactions ----------

When('I select {string} from the team dropdown') do |team_name|
  if page.has_css?('.assign-section')
    within('.assign-section') do
      begin
        select team_name, from: 'Assign to team:'
      rescue Capybara::ElementNotFound
        if page.has_select?('ticket[team_id]')
          select team_name, from: 'ticket[team_id]'
        else
          raise
        end
      end
    end
  else
    if page.has_select?('ticket[team_id]')
      select team_name, from: 'ticket[team_id]'
    else
      select team_name, from: 'Assign to team:'
    end
  end
end


# ---------- Multi-message matcher ----------

Then('I should see one of:') do |table|
  messages = table.raw.flatten
  expect(messages.any? { |m| page.has_content?(m) }).to be(true),
    -> { "Expected page to include one of:\n  - #{messages.join("\n  - ")}\nBut got:\n#{page.text}" }
end

# ---- helpers ----
def find_or_create_agent!(name)
  email = "#{name.downcase.gsub(/\s+/, '.')}@example.com"
  User.find_or_create_by!(email: email) do |u|
    u.provider = "google_oauth2"
    u.uid      = "staff-#{email}"
    u.role     = :staff
    u.name     = name
  end
end

def find_or_create_requester!(name)
  email = "#{name.downcase.gsub(/\s+/, '.')}@example.com"
  User.find_or_create_by!(email: email) do |u|
    u.provider = "google_oauth2"
    u.uid      = "user-#{email}"
    u.role     = :user
    u.name     = name
  end
end

# ---- Given steps ----

Given('there is a team named {string}') do |team_name|
  Team.find_or_create_by!(name: team_name)
end

Given('there is an agent named {string} in team {string}') do |agent_name, team_name|
  user = find_or_create_agent!(agent_name)
  team = Team.find_or_create_by!(name: team_name)
  TeamMembership.find_or_create_by!(team: team, user: user)
end

Given('the ticket is currently assigned to team {string} and agent {string}') do |team_name, agent_name|
  ticket = current_ticket!
  ticket.reload
  team = Team.find_or_create_by!(name: team_name)
  agent = find_or_create_agent!(agent_name)
  # ensure membership to satisfy model validation
  TeamMembership.find_or_create_by!(team: team, user: agent)
  @ticket.update!(team: team, assignee: agent)
end

Given('{string} is NOT a member of team {string}') do |agent_name, team_name|
  user = User.find_by!(name: agent_name)
  team = Team.find_by!(name: team_name)
  TeamMembership.where(team: team, user: user).delete_all
end

# ---- When steps ----

When('I leave the agent dropdown unassigned') do
  if page.has_css?('.assign-section')
    within('.assign-section') do
      # Prefer selecting the explicit blank option text
      if page.has_select?('Assign to agent:', with_options: [ 'Unassigned' ])
        select 'Unassigned', from: 'Assign to agent:'
      else
        find('#ticket_assignee_id', visible: :all).set('')
      end
    end
  else
    if page.has_select?('Assign to agent:', with_options: [ 'Unassigned' ])
      select 'Unassigned', from: 'Assign to agent:'
    else
      find('#ticket_assignee_id', visible: :all).set('')
    end
  end
end

# ---- Then steps ----

Then("the ticket's team should be {string}") do |team_name|
  ticket = current_ticket!
  ticket.reload
  expect(ticket.team&.name).to eq(team_name)
  expect(page.body).to include(team_name)
end

Then('the ticket should be unassigned to any agent') do
  ticket = current_ticket!
  ticket.reload
  expect(ticket.assignee).to be_nil
  expect(page.body).to match(/Assignee:\s*(Unassigned|<\/dt>\s*<dd>\s*Unassigned)/)
end
