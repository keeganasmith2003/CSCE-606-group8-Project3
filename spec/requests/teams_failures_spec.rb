require "rails_helper"

RSpec.describe "Teams failures and auth", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user, :requester) }

  describe "create/update invalid" do
    it "renders new on invalid create" do
      sign_in(admin)
      post teams_path, params: { team: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("field_with_errors")
      expect(response.body).to include("Create Team")
    end

    it "renders edit on invalid update" do
      sign_in(admin)
      team = Team.create!(name: "Alpha")
      patch team_path(team), params: { team: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("field_with_errors")
      expect(response.body).to include("Update Team")
    end
  end

  describe "destroy with tickets" do
    it "cannot delete team that has tickets" do
      sign_in(admin)
      team = Team.create!(name: "Support")
      requester = create(:user, :requester)
      Ticket.create!(subject: "Test Ticket", description: "Test Description", priority: :medium, category: Ticket::CATEGORY_OPTIONS.first, requester: requester, team: team)
      delete team_path(team)
      expect(response).to redirect_to(team_path(team))
      follow_redirect!
      expect(response.body).to include("Cannot delete a team with assigned tickets")
    end
  end

  describe "authorization" do
    it "prevents non-admin from creating a team" do
      sign_in(user)
      expect {
        post teams_path, params: { team: { name: "X" } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
