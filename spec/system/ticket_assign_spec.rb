# spec/requests/ticket_assignment_spec.rb
require "rails_helper"

RSpec.describe "Ticket assignment", type: :request do
  it "allows staff/sysadmin to set team and assignee" do
    staff = User.create!(provider: "google_oauth2", uid: "s1", email: "staff@example.com", role: :staff, name: "Alice")
    bob   = User.create!(provider: "google_oauth2", uid: "s2", email: "bob@example.com",   role: :staff, name: "Bob")
    team  = Team.create!(name: "Support")
    TeamMembership.create!(team: team, user: bob)

    requester = User.create!(provider: "google_oauth2", uid: "r1", email: "charlie@example.com", role: :user, name: "Charlie")
    ticket = Ticket.create!(
      subject: "Test Ticket",
      description: "Body",
      requester_id: requester.id,
      status: :open,
      category: Ticket::CATEGORY_OPTIONS.first
    )

    # Sign in without any browser
    sign_in(staff)

    # Exercise the assignment endpoint directly
    patch assign_ticket_path(ticket), params: {
      ticket: {
        team_id: team.id,
        assignee_id: bob.id
      }
    }

    # Should redirect back to the ticket page
    expect(response).to redirect_to(ticket_path(ticket))
    follow_redirect!

    ticket.reload
    expect(ticket.team).to eq(team)
    expect(ticket.assignee).to eq(bob)

    # Flash could be specific or generic depending on your controller
    expect(flash[:notice]).to match(/Ticket assigned to Bob|Ticket assignment updated\./)
  end
end
