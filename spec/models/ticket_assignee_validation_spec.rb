require "rails_helper"

RSpec.describe Ticket, "assignee must belong to team" do
  let!(:team) { Team.create!(name: "A Team") }
  let!(:member) { create(:user, :agent) }
  let!(:non_member) { create(:user, :agent) }
  let!(:requester) { create(:user, :requester) }

  before do
    TeamMembership.create!(team: team, user: member)
  end

  it "is valid when assignee is a member of the team" do
    t = Ticket.new(subject: "S", description: "D", category: Ticket::CATEGORY_OPTIONS.first, requester: requester, team: team, assignee: member)
    expect(t).to be_valid
  end
end
