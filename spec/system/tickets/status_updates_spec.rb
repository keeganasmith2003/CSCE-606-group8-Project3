require "rails_helper"

RSpec.describe "Ticket status and comments", type: :system do
  let(:requester) { create(:user, :requester) }
  let(:staff) { create(:user, :agent) }

  before do
    driven_by(:rack_test)
  end

  it "allows staff to update status and add internal comments" do
    ticket = create(:ticket, requester: requester, status: :open)

    sign_in(staff)
    visit ticket_path(ticket)

    select "On Hold", from: "ticket[status]"
    click_button "Go"

    expect(page).to have_css(".status-badge", text: "On Hold")

    fill_in "comment[body]", with: "Internal triage note"
    select "Internal", from: "comment[visibility]"
    click_button "Comment"

    expect(page).to have_content("Comment added successfully.")
    within(".comments-list") do
      expect(page).to have_content("Internal")
      expect(page).to have_content("Internal triage note")
    end
  end

  it "restricts requesters to public comments only" do
    ticket = create(:ticket, requester: requester, status: :in_progress)
    create(:comment, ticket: ticket, author: staff, visibility: :internal, body: "Internal diagnosis")
    create(:comment, ticket: ticket, author: requester, visibility: :public, body: "Any update?")

    sign_in(requester)
    visit ticket_path(ticket)

    expect(page).not_to have_button("Go")
    expect(page).to have_css(".status-badge", text: "In Progress")
    within(".comments-list") do
      expect(page).to have_content("Any update?")
      expect(page).not_to have_content("Internal diagnosis")
    end

    fill_in "comment[body]", with: "Thanks for the update"
    click_button "Comment"

    expect(page).to have_content("Comment added successfully.")
    within(".comments-list") do
      expect(page).to have_content("Thanks for the update")
      expect(page).to have_content("Public")
    end
  end
end
