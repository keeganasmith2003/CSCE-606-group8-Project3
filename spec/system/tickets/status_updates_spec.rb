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

<<<<<<< HEAD
    select "On Hold", from: "ticket_status"
=======
    select "On Hold", from: "ticket[status]"
>>>>>>> d7f7a33e94ac097e6f0d21e753bd97743e7d1fa6
    click_button "Go"

    expect(page).to have_css(".status-badge", text: "On Hold")

<<<<<<< HEAD
    fill_in "Leave a comment", with: "Internal triage note"
    select "Internal", from: "comment_visibility"
=======
    fill_in "comment[body]", with: "Internal triage note"
    select "Internal", from: "comment[visibility]"
>>>>>>> d7f7a33e94ac097e6f0d21e753bd97743e7d1fa6
    click_button "Comment"

    expect(page).to have_content("Internal triage note")
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

<<<<<<< HEAD
    fill_in "Leave a comment", with: "Thanks for the update"
=======
    fill_in "comment[body]", with: "Thanks for the update"
>>>>>>> d7f7a33e94ac097e6f0d21e753bd97743e7d1fa6
    click_button "Comment"

    within(".comments-list") do
      expect(page).to have_content("Thanks for the update")
      expect(page).to have_content("Public")
    end
  end
end
