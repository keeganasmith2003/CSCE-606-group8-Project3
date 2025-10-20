# features/step_definitions/ticket_steps.rb

# Navigation steps
Given("I am on the new ticket page") do
  visit new_ticket_path
end

Given("I am on the tickets list page") do
  visit tickets_path
end

Given("I go to the tickets list page") do
  visit tickets_path
end

Given("I am on the edit page for {string}") do |ticket_title|
  ticket = Ticket.find_by(title: ticket_title)
  visit edit_ticket_path(ticket)
end

Given("I am on the ticket page for {string}") do |ticket_title|
  ticket = Ticket.find_by(title: ticket_title)
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
  table.hashes.each do |ticket_attrs|
    Ticket.create!(ticket_attrs)
  end
end
