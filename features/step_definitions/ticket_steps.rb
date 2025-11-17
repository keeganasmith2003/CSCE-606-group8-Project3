# features/step_definitions/ticket_steps.rb

# Navigation steps
Given("I am on the home page") do
  visit root_path
end

Given("I am on the new ticket page") do
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: "google_oauth2",
    uid: "test-uid",
    info: { email: "test@example.com", name: "Test User" }
  )
  visit "/auth/google_oauth2"
  visit new_ticket_path
end

Given("I am on the tickets list page") do
  visit tickets_path
end

Given("I go to the tickets list page") do
  visit tickets_path
end

Given("I am on the edit page for {string}") do |subject|
  ticket = Ticket.find_by(subject: subject)
  visit edit_ticket_path(ticket)
end

Given("I am on the ticket page for {string}") do |ticket_title|
  ticket = Ticket.find_by(subject: ticket_title)
  visit ticket_path(ticket)
end

# Form filling steps
When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

# Button/link clicking steps
When("I press {string}") do |button_or_link|
  click_link_or_button button_or_link
end

When("I press {string} within the assignment form") do |button_or_link|
  within("form[action*='assign']") do
    click_link_or_button button_or_link
  end
end

# Page expectation steps
Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should see {string} in the navbar") do |text|
  within('.navbar') do
    expect(page).to have_content(text)
  end
end

Then("I should see {string} in the ticket list") do |ticket_title|
  visit tickets_path unless current_path == tickets_path
  expect(page).to have_content(ticket_title)
end

Then("I should not see {string} in the ticket list") do |ticket_title|
  visit tickets_path unless current_path == tickets_path
  expect(page).not_to have_content(ticket_title)
end

Then("I should not see {string}") do |ticket_title|
  expect(page).not_to have_content(ticket_title)
end

# Background / fixture steps
require "securerandom"

Given("the following tickets exist:") do |table|
  table.hashes.each do |original_row|
    row = original_row.dup

    # --- requester (backward compatible) ---
    requester_email = row.delete("requester_email") || "testuser@example.com"

    requester = User.find_or_initialize_by(email: requester_email)
    requester.provider ||= "seed"
    requester.uid      ||= SecureRandom.uuid
    requester.role     ||= "user"
    requester.name     ||= "Test Requester"
    requester.save!

    # --- optional assignee (for filtering by assignee) ---
    assignee = nil
    if row["assignee_email"].present?
      assignee_email = row.delete("assignee_email")
      assignee = User.find_or_initialize_by(email: assignee_email)
      assignee.provider ||= "seed"
      assignee.uid      ||= SecureRandom.uuid
      assignee.role     ||= "user"
      assignee.name     ||= assignee_email
      assignee.save!
    end

    # --- core attributes (with sane defaults, same as before) ---
    status   = row["status"].presence   || "open"
    priority = row["priority"].presence || "low"
    category = row["category"].presence || Ticket::CATEGORY_OPTIONS.first

    # --- approval attributes (for filtering by approval_status) ---
    approval_status = row["approval_status"].presence
    # default to pending if not provided (keeps older tests happy)
    approval_status ||= "pending"

    approval_reason = row["approval_reason"].presence
    # model requires approval_reason when approval_status == :rejected
    if approval_status.to_s == "rejected" && approval_reason.blank?
      approval_reason = "Rejected for test"
    end

    Ticket.create!(
      subject:         row["subject"],
      description:     row["description"],
      status:          status,
      priority:        priority,
      category:        category,
      requester:       requester,
      assignee:        assignee,
      approval_status: approval_status,
      approval_reason: approval_reason
    )
  end
end




# Assignment-specific steps
Given("there is an agent named {string}") do |name|
  FactoryBot.create(:user, :agent, name: name)
end

Given("there is a requester named {string}") do |name|
  FactoryBot.create(:user, :requester, name: name)
end

Given("there is an unassigned ticket created by {string}") do |name|
  requester = User.find_by(name: name)
  FactoryBot.create(:ticket, subject: "Test Ticket", description: "Test description", requester: requester, assignee: nil)
end

Given("the assignment strategy is set to {string}") do |strategy|
  Setting.set('assignment_strategy', strategy)
end

Given("I am logged in as agent {string}") do |name|
  user = User.find_by(name: name)
  if user
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: user.uid,
      info: { email: user.email, name: user.name }
    )
    visit "/auth/google_oauth2"
  end
end

When("I visit the ticket page") do
  ticket = Ticket.last
  visit ticket_path(ticket)
end

When("I select {string} from the agent dropdown") do |agent_name|
  agent = User.find_by(name: agent_name)
  select agent_name, from: 'ticket[assignee_id]'
end

def next_agent_in_rotation
  agents = User.where(role: :staff).order(:id)
  return agents.first if agents.empty?

  last_assigned_index = Setting.get("last_assigned_index")
  if last_assigned_index.nil?
    index = 0
  else
    index = (last_assigned_index.to_i + 1) % agents.size
  end
  Setting.set("last_assigned_index", index.to_s)
  agents[index]
end

When("{string} creates a new ticket") do |name|
  requester = User.find_by(name: name)
  if requester
    # Simulate the user being logged in by setting current_user context
    # Since we're using OmniAuth, we need to create the ticket directly
    ticket = Ticket.new(
      subject: 'New Ticket',
      description: 'Ticket description',
      status: :open,
      priority: :medium,
      category: Ticket::CATEGORY_OPTIONS.first,
      requester: requester
    )

    # Apply auto-assignment logic from controller
    if Setting.auto_round_robin?
      ticket.assignee = next_agent_in_rotation
    end

    ticket.save!
  end
end

When("{string} creates another new ticket") do |name|
  step "\"#{name}\" creates a new ticket"
end

Then("the ticket should be assigned to {string}") do |agent_name|
  agent = User.find_by(name: agent_name)
  ticket = Ticket.last
  expect(ticket&.assignee).to eq(agent)
end

Then("the ticket should remain unassigned") do
  ticket = Ticket.last
  expect(ticket&.assignee).to be_nil
end

Then("the ticket should be automatically assigned to {string}") do |agent_name|
  step "the ticket should be assigned to \"#{agent_name}\""
end

When("I select {string} from {string}") do |option, field_label|
  # Try exact match first
  begin
    select option, from: field_label
  rescue Capybara::ElementNotFound
    # Fallback: try titleized version for enum dropdowns (e.g., "open" → "Open")
    begin
      select option.titleize, from: field_label
    rescue Capybara::ElementNotFound => e
      # For status, try capitalized (e.g., "closed" → "Closed")
      begin
        select option.capitalize, from: field_label
      rescue Capybara::ElementNotFound
        # Helpful debug output when all attempts fail
        raise Capybara::ElementNotFound, "Unable to find option '#{option}' (or '#{option.titleize}' or '#{option.capitalize}') for field '#{field_label}'. Original error: #{e.message}"
      end
    end
  end
end
