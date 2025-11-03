require "rails_helper"

RSpec.describe TeamMembership, type: :model do
  it "enforces user uniqueness per team" do
    team = Team.create!(name: "Support")
    user = User.create!(provider: "google_oauth2", uid: "u1", email: "a@a.com", role: :staff)
    TeamMembership.create!(team: team, user: user)

    dup = TeamMembership.new(team: team, user: user)
    expect(dup).to be_invalid
    expect(dup.errors[:user_id]).to be_present
  end
end
