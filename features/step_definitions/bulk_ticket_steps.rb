# -------------------------------------------
# Selecting tickets for bulk actions
# -------------------------------------------
When('I select the ticket {string} for bulk actions') do |subject|
  # Limit to the form that has the Bulk action select (so we ignore "Recent tickets" etc.)
  form = find(:xpath, "//form[.//label[contains(normalize-space(.), 'Bulk action')]]", match: :first)

  within(form) do
    # Now there should only be one matching card per ticket
    card = find('.ticket-card', text: subject, match: :first)

    within(card) do
      find("input[type='checkbox'][name='ticket_ids[]']", visible: :all).set(true)
    end
  end
end

# -------------------------------------------
# Selecting bulk action
# -------------------------------------------
When('I choose {string} from the {string} select') do |option, select_label|
  select option, from: select_label
end

# -------------------------------------------
# Verifying ticket status
# -------------------------------------------
Then('the ticket {string} should have status {string}') do |subject, status|
  ticket = Ticket.find_by!(subject: subject)
  expect(ticket.status.to_s).to eq(status)
end

# -------------------------------------------
# Assign ticket to agent
# -------------------------------------------
Given('ticket {string} is assigned to agent {string}') do |subject, agent_name|
  ticket = Ticket.find_by!(subject: subject)
  agent  = User.find_by!(name: agent_name)
  ticket.update!(assignee: agent)
end

# -------------------------------------------
# Navigate to personal dashboard
# -------------------------------------------
When('I go to my tickets dashboard page') do
  visit personal_dashboard_path   # ← correct route from your routes.rb
end

# -------------------------------------------
# Create a requester user
# -------------------------------------------
Given('there is a requester named {string} with email {string}') do |name, email|
  user = User.find_or_initialize_by(email: email.downcase)
  user.assign_attributes(
    name: name,
    role: :user,
    provider: user.provider.presence || "test",
    uid: user.uid.presence || SecureRandom.uuid
  )
  user.save!
end

# -------------------------------------------
# Login using your existing helper
# -------------------------------------------
When('I am logged in as requester {string}') do |name|
  step %(I am logged in as "#{name}")     # delegates to your universal login step
end
