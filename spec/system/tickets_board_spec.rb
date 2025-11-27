require "rails_helper"

RSpec.describe "Tickets board", type: :system do
  let(:user) { create(:user, :agent) }
  let(:requester) { create(:user, :requester) }

  before do
    driven_by(:rack_test)
  end

  it "displays kanban board with columns for all statuses" do
    sign_in(user)

    create(:ticket, subject: "Open Task", status: :open, requester: requester)
    create(:ticket, subject: "In Progress Task", status: :in_progress, requester: requester)
    create(:ticket, subject: "On Hold Task", status: :on_hold, requester: requester)
    create(:ticket, subject: "Resolved Task", status: :resolved, requester: requester)

    visit board_tickets_path

    expect(page).to have_content("Tickets Board")
    expect(page).to have_content("Open")
    expect(page).to have_content("In Progress")
    expect(page).to have_content("On Hold")
    expect(page).to have_content("Resolved")
  end

  it "groups tickets into their respective status columns" do
    sign_in(user)

    open_ticket_1 = create(:ticket, subject: "Bug Fix 1", status: :open, requester: requester)
    open_ticket_2 = create(:ticket, subject: "Bug Fix 2", status: :open, requester: requester)
    in_progress_ticket = create(:ticket, subject: "Feature Development", status: :in_progress, requester: requester)

    visit board_tickets_path

    # Find the Open column and check both tickets are there
    open_column = find_column("Open")
    expect(open_column).to have_content("Bug Fix 1")
    expect(open_column).to have_content("Bug Fix 2")

    # Find the In Progress column and check only the right ticket is there
    in_progress_column = find_column("In Progress")
    expect(in_progress_column).to have_content("Feature Development")
    expect(in_progress_column).not_to have_content("Bug Fix 1")
  end

  it "displays empty columns when no tickets exist in a status" do
    sign_in(user)

    # Only create an open ticket, leaving other statuses empty
    create(:ticket, subject: "Only Open Ticket", status: :open, requester: requester)

    visit board_tickets_path

    expect(page).to have_content("Open")
    expect(page).to have_content("In Progress")
    expect(page).to have_content("On Hold")
    expect(page).to have_content("Resolved")

    # Open column should have a ticket
    open_column = find_column("Open")
    expect(open_column).to have_content("Only Open Ticket")

    # Other columns should exist but be empty
    in_progress_column = find_column("In Progress")
    expect(in_progress_column).not_to have_content("Only Open Ticket")
  end

  it "displays ticket priority and assignee in cards" do
    sign_in(user)

    assignee = create(:user, :agent, name: "Alice")
    ticket = create(:ticket, subject: "Priority Task", status: :open, priority: :high, assignee: assignee, requester: requester)

    visit board_tickets_path

    open_column = find_column("Open")
    within(open_column) do
      expect(page).to have_content("Priority Task")
      expect(page).to have_content("High")
      expect(page).to have_content("Alice")
    end
  end

  it "requires authentication to access board" do
    visit board_tickets_path
    # Unauthenticated users should be redirected to login (OmniAuth)
    expect(current_path).not_to eq(board_tickets_path)
  end

  it "links from board cards to ticket details" do
    sign_in(user)

    ticket = create(:ticket, subject: "Clickable Task", status: :open, requester: requester)

    visit board_tickets_path

    open_column = find_column("Open")
    within(open_column) do
      click_link("Clickable Task")
    end

    expect(page).to have_current_path(ticket_path(ticket))
    expect(page).to have_content("Clickable Task")
  end

  # Helper to find a kanban column by header text
  def find_column(status_name)
    all(".kanban-column").find { |col| col.has_content?(status_name) }
  end
end
