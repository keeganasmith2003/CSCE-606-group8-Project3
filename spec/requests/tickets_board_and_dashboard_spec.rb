require "rails_helper"

RSpec.describe "Tickets board and dashboard", type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe "GET /tickets/board" do
    before do
      sign_in(user)
      FactoryBot.create(:ticket, subject: "Open One", status: :open, requester: user)
      FactoryBot.create(:ticket, subject: "In Progress One", status: :in_progress, requester: user)
    end

    it "renders kanban board with status columns" do
      get board_tickets_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Open")
      expect(response.body).to include("In Progress")
      expect(response.body).to include("Open One")
      expect(response.body).to include("In Progress One")
    end
  end

  describe "GET /dashboard" do
    before do
      sign_in(user)
      FactoryBot.create(:ticket, subject: "My Open", status: :open, assignee: user, requester: user)
      FactoryBot.create(:ticket, subject: "My Resolved", status: :resolved, assignee: user, requester: user)
    end

    it "shows counts and lists tickets assigned to current user grouped by status" do
      get personal_dashboard_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("My Tickets Dashboard")
      expect(response.body).to include("Open")
      expect(response.body).to include("Resolved")
      expect(response.body).to include("My Open")
      expect(response.body).to include("My Resolved")
    end
  end
end
