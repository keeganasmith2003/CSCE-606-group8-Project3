# features/step_definitions/ticket_steps.rb

# Navigation steps
Given("I am on the home page") do
  visit root_path
end

Given("I am on the new ticket page") do
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

# Page expectation steps
Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should see {string} in the ticket list") do |ticket_title|
  visit tickets_path unless current_path == tickets_path
  expect(page).to have_content(ticket_title)
end

Then("I should not see {string}") do |ticket_title|
  expect(page).not_to have_content(ticket_title)
end

# Background / fixture steps
Given("the following tickets exist:") do |table|
  table.hashes.each do |row|
    # Find or create the requester
    requester_email = row.delete("requester_email") || "testuser@example.com"
    # Find by email to avoid creating duplicate users (OmniAuth test helper may have already
    # created a user with this email). Only set missing attributes.
    requester = User.find_or_initialize_by(email: requester_email)
    requester.provider ||= "seed"
    requester.uid ||= SecureRandom.uuid
    requester.role ||= "user"
    requester.name ||= "Test Requester"
    requester.save!

    # Create the ticket with a valid requester
    Ticket.create!(
      subject: row["subject"],
      description: row["description"],
      status: row["status"] || "open",
      priority: row["priority"] || "low",
      category: row["category"] || "General",
      requester: requester
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

Given("I am logged in as {string}") do |name|
  user = User.find_by(name: name)
  login_as(user, scope: :user)
end

Given("there is an unassigned ticket created by {string}") do |name|
  requester = User.find_by(name: name)
  FactoryBot.create(:ticket, subject: "Test Ticket", description: "Test description", requester: requester, assignee: nil)
end

Given("the assignment strategy is set to {string}") do |strategy|
  Setting.set('assignment_strategy', strategy)
end

When("I visit the ticket page") do
  ticket = Ticket.last
  visit ticket_path(ticket)
end

When("I select {string} from the agent dropdown") do |agent_name|
  agent = User.find_by(name: agent_name)
  select agent_name, from: 'agent_id'
end

When("{string} creates a new ticket") do |name|
  requester = User.find_by(name: name)
  login_as(requester, scope: :user)
  visit new_ticket_path
  fill_in 'Subject', with: 'New Ticket'
  fill_in 'Description', with: 'Ticket description'
  select 'normal', from: 'Priority'
  click_button 'Create Ticket'
end

When("{string} creates another new ticket") do |name|
  step "#{name} creates a new ticket"
end

Then("the ticket should be assigned to {string}") do |agent_name|
  agent = User.find_by(name: agent_name)
  ticket = Ticket.last
  expect(ticket.assignee).to eq(agent)
end

Then("the ticket should remain unassigned") do
  ticket = Ticket.last
  expect(ticket.assignee).to be_nil
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
      # Helpful debug output when both attempts fail
      raise Capybara::ElementNotFound, "Unable to find option '#{option}' (or '#{option.titleize}') for field '#{field_label}'. Original error: #{e.message}"
    end
  end
end
