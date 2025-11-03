require "rails_helper"

RSpec.describe Team, type: :model do
  it "validates name presence and uniqueness (case-insensitive)" do
    Team.create!(name: "Support")
    dup = Team.new(name: "support")
    expect(dup).to be_invalid
    expect(dup.errors[:name]).to be_present
  end

  it "has members through team_memberships" do
    team = Team.create!(name: "Support")
    user = User.create!(provider: "google_oauth2", uid: "u1", email: "a@a.com", role: :staff)
    TeamMembership.create!(team: team, user: user)
    expect(team.members).to include(user)
  end
end
