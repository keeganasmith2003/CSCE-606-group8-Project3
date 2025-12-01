require "rails_helper"

RSpec.describe "Tickets dashboard", type: :system do
  let(:agent) { create(:user, :agent, name: "Bob") }
  let(:requester) { create(:user, :requester) }

  before do
    driven_by(:rack_test)
  end

  it "displays dashboard after user signs in" do
    sign_in(agent)
    visit root_path

  expect(page).to have_current_path(personal_dashboard_path)
  expect(page).to have_content("My Tickets Dashboard")
  end

  it "shows counts and lists of tickets assigned to the current user" do
    sign_in(agent)

    create(:ticket, subject: "My Open Task", status: :open, assignee: agent, requester: requester)
    create(:ticket, subject: "My In Progress Task", status: :in_progress, assignee: agent, requester: requester)
    create(:ticket, subject: "My Resolved Task", status: :resolved, assignee: agent, requester: requester)
    # Create an unassigned ticket
    create(:ticket, subject: "Someone Else Task", status: :open, requester: requester)

  visit personal_dashboard_path

    expect(page).to have_content("Open (1)")
    expect(page).to have_content("In Progress (1)")
    expect(page).to have_content("Resolved (1)")

    expect(page).to have_content("My Open Task")
    expect(page).to have_content("My In Progress Task")
    expect(page).to have_content("My Resolved Task")
    expect(page).not_to have_content("Someone Else Task")
  end

  it "groups tickets by status on the dashboard" do
    sign_in(agent)

    create(:ticket, subject: "Task A", status: :open, priority: :high, assignee: agent, requester: requester)
    create(:ticket, subject: "Task B", status: :open, priority: :low, assignee: agent, requester: requester)
    create(:ticket, subject: "Task C", status: :in_progress, priority: :medium, assignee: agent, requester: requester)

  visit personal_dashboard_path

    # Find the Open section
    expect(page).to have_content("Open (2)")
    within(".dashboard-status", text: "Open") do
      expect(page).to have_content("Task A")
      expect(page).to have_content("Task B")
      expect(page).not_to have_content("Task C")
    end

    # Find the In Progress section
    expect(page).to have_content("In Progress (1)")
    within(".dashboard-status", text: "In Progress") do
      expect(page).to have_content("Task C")
      expect(page).not_to have_content("Task A")
    end
  end

  it "shows priority labels on dashboard ticket list" do
    sign_in(agent)

    create(:ticket, subject: "High Priority", status: :open, priority: :high, assignee: agent, requester: requester)
    create(:ticket, subject: "Low Priority", status: :open, priority: :low, assignee: agent, requester: requester)

  visit personal_dashboard_path

    within(".dashboard-status", text: "Open") do
      expect(page).to have_content("High Priority")
      expect(page).to have_content("High")
      expect(page).to have_content("Low Priority")
      expect(page).to have_content("Low")
    end
  end

  it "links dashboard ticket items to ticket details" do
    sign_in(agent)

    ticket = create(:ticket, subject: "Clickable Ticket", status: :open, assignee: agent, requester: requester)

  visit personal_dashboard_path

  find_link("Clickable Ticket", match: :first).click

  expect(page).to have_current_path(ticket_path(ticket))
    expect(page).to have_content("Clickable Ticket")
  end

  it "redirects to dashboard after sign-in" do
    sign_in(agent)

  expect(page).to have_current_path(personal_dashboard_path)
  end

  it "shows accurate counts even when tickets exist for other users" do
    other_agent = create(:user, :agent, name: "Charlie")

    sign_in(agent)

    # Create tickets for the current user
    create(:ticket, subject: "My Task 1", status: :open, assignee: agent, requester: requester)
    create(:ticket, subject: "My Task 2", status: :open, assignee: agent, requester: requester)

    # Create tickets assigned to another user
    create(:ticket, subject: "Charlie Task 1", status: :open, assignee: other_agent, requester: requester)

  visit personal_dashboard_path

    # Current user should see only their own tickets
    expect(page).to have_content("Open (2)")
    expect(page).to have_content("My Task 1")
    expect(page).to have_content("My Task 2")
    expect(page).not_to have_content("Charlie Task 1")
  end
end
