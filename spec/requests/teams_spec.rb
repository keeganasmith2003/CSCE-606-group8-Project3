require "rails_helper"

RSpec.describe "Teams", type: :request do
  let(:admin) { User.create!(provider: "google_oauth2", uid: "a1", email: "admin@example.com", role: :sysadmin) }

  describe "CRUD" do
    it "admin can create, view, update, and destroy" do
      sign_in(admin)

      # create
      post teams_path, params: { team: { name: "Support", description: "Helpdesk" } }
      expect(response).to redirect_to(team_path(Team.last))
      follow_redirect!
      expect(response.body).to include("Support")

      # update
      patch team_path(Team.last), params: { team: { description: "Tier 1" } }
      expect(response).to redirect_to(team_path(Team.last))
      follow_redirect!
      expect(response.body).to include("Tier 1")

      # destroy (no tickets)
      delete team_path(Team.last)
      expect(response).to redirect_to(teams_path)
    end
  end

  describe "index scope" do
    it "staff only sees their teams" do
      staff = User.create!(provider: "google_oauth2", uid: "u2", email: "staff@example.com", role: :staff)
      t1 = Team.create!(name: "Support")
      t2 = Team.create!(name: "Ops")
      TeamMembership.create!(team: t1, user: staff)

      sign_in(staff)
      get teams_path
      expect(response.body).to include("Support")
      expect(response.body).not_to include("Ops")
    end
  end
end
