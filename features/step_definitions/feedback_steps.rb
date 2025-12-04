# frozen_string_literal: true

module FeedbackHelpers
  def find_or_create_user(name, role)
    email = "#{name.parameterize}@example.com"

    User.find_or_create_by!(email: email) do |u|
      u.name     = name
      u.provider = "test"
      u.uid      = "#{name.parameterize}-uid"
      u.role     = role
    end
  end

  def create_ticket!(subject:, requester:, status:)
    Ticket.create!(
      subject:       subject,
      description:   "Test description for #{subject}",
      status:        status,               # :open or :resolved (enum)
      priority:      :medium,
      category:      "Technical Issue",
      requester:     requester,
      approval_status: :pending
    )
  end
end

World(FeedbackHelpers)

Given("a user {string} exists with role {string}") do |name, role|
  find_or_create_user(name, role)
end

Given("a staff user {string} exists with role {string}") do |name, role|
  # Just delegates to the generic one; kept for readability in feature file
  find_or_create_user(name, role)
end

Given("a resolved ticket {string} requested by {string}") do |subject, requester_name|
  requester = find_or_create_user(requester_name, :user)
  create_ticket!(subject: subject, requester: requester, status: :resolved)
end

Given("a resolved ticket {string} requested by {string} with rating {int} and feedback {string}") do |subject, requester_name, rating, feedback|
  requester = find_or_create_user(requester_name, :user)
  ticket = create_ticket!(subject: subject, requester: requester, status: :resolved)
  ticket.update!(
    customer_service_rating:      rating,
    customer_service_feedback:    feedback,
    customer_service_rated_at:    Time.current
  )
end

Given("an open ticket {string} requested by {string}") do |subject, requester_name|
  requester = find_or_create_user(requester_name, :user)
  create_ticket!(subject: subject, requester: requester, status: :open)
end

When("I visit the ticket page for {string}") do |subject|
  ticket = Ticket.find_by!(subject: subject)
  visit ticket_path(ticket)
end

When("I visit the tickets index") do
  visit tickets_path
end

When("I rate the ticket {string} with {int} stars and feedback {string}") do |subject, stars, feedback|
  ticket = Ticket.find_by!(subject: subject)
  visit ticket_path(ticket)

  # Select the appropriate radio button for the star rating
  # Inputs are created by form_with as ticket[customer_service_rating]
  # and we gave them ids like ticket_rating_1..5
  find("input#ticket_rating_#{stars}", visible: :all).choose

  fill_in "ticket_customer_service_feedback", with: feedback

  click_button "Submit Feedback"
end

Then("I should see the rating stars for feedback") do
  # Just check presence of the star container; you can make this stricter if you want
  expect(page).to have_css(".star-rating")
end

Then("I should see {string} within the ticket card for {string}") do |text, subject|
  card = page.find("article.ticket-card", text: subject)
  expect(card).to have_content(text)
end

When("I attempt to visit the ticket page for {string}") do |subject|
  ticket = Ticket.find_by!(subject: subject)

  begin
    visit ticket_path(ticket)
  rescue Pundit::NotAuthorizedError => e
    @authorization_error = e
  end
end

Then("I should be unauthorized") do
  expect(@authorization_error).to be_a(Pundit::NotAuthorizedError)
end