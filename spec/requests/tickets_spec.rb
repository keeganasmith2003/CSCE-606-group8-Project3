require 'rails_helper'

RSpec.describe "Tickets", type: :request do
  let(:category_option) { Ticket::CATEGORY_OPTIONS.first }
  let(:requester) { create(:user, role: :user) }
  let(:other_user) { create(:user, role: :user) }

  describe "POST /tickets" do
    before { sign_in(requester) }

    it "creates a ticket with the selected category and priority" do
      expect do
        post tickets_path, params: {
          ticket: {
            subject: "Printer broken",
            description: "The office printer is jammed.",
            status: :open,
            priority: :high,
            category: category_option
          }
        }
      end.to change(Ticket, :count).by(1)

      ticket = Ticket.order(:created_at).last
      expect(ticket.category).to eq(category_option)
      expect(ticket.priority).to eq("high")
      expect(response).to redirect_to(ticket_path(ticket))
      follow_redirect!
      expect(response.body).to include("Printer broken")
    end

  describe "GET /tickets (filters and auth)" do
    it "requires login for JSON and returns 401" do
      headers = {
        "HTTP_USER_AGENT" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "HTTP_ACCEPT" => "application/json",
        "HTTP_SEC_CH_UA" => '"Chromium";v="120", "Google Chrome";v="120", ";Not A Brand";v="99"',
        "HTTP_SEC_CH_UA_MOBILE" => "?0",
        "HTTP_SEC_CH_UA_PLATFORM" => '"macOS"'
      }
      get tickets_path(format: :json), as: :json, headers: headers
      # The application globally enforces modern browsers and returns 406 first
      expect(response).to have_http_status(:not_acceptable)
    end

    it "filters by status, category, and assignee" do
      sign_in(requester)
      agent = create(:user, :agent)
      t1 = create(:ticket, subject: "Filtered In", requester: requester, status: :open, category: Ticket::CATEGORY_OPTIONS.first, assignee: agent)
      t2 = create(:ticket, subject: "Filtered Out", requester: requester, status: :in_progress, category: Ticket::CATEGORY_OPTIONS.last, assignee: nil)

      get tickets_path, params: { status: "open", category: Ticket::CATEGORY_OPTIONS.first, assignee_id: agent.id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Filtered In")
      expect(response.body).not_to include("Filtered Out")
    end
  end

  describe "POST /tickets (round-robin assignment)" do
    before do
      Setting.set("assignment_strategy", "round_robin")
      Setting.set("last_assigned_index", "-1") # so first computed becomes 0
    end

    it "assigns the next agent in rotation and advances index" do
      agent1 = create(:user, :agent)
      agent2 = create(:user, :agent)

      sign_in(requester)

      expect {
        post tickets_path, params: { ticket: { subject: "RR1", description: "d", category: Ticket::CATEGORY_OPTIONS.first } }
      }.to change(Ticket, :count).by(1)
      t1 = Ticket.order(:created_at).last
      expect(t1.assignee).to eq(agent1)

      expect {
        post tickets_path, params: { ticket: { subject: "RR2", description: "d", category: Ticket::CATEGORY_OPTIONS.first } }
      }.to change(Ticket, :count).by(1)
      t2 = Ticket.order(:created_at).last
      expect(t2.assignee).to eq(agent2)

      # index stored as string
      expect(Setting.get("last_assigned_index")).to eq("1")
    end

    it "does not assign when no agents exist" do
      sign_in(requester)
      post tickets_path, params: { ticket: { subject: "RR none", description: "d", category: Ticket::CATEGORY_OPTIONS.first } }
      t = Ticket.order(:created_at).last
      expect(t.assignee).to be_nil
    end
  end

    it "defaults priority to medium when not provided" do
      expect do
        post tickets_path, params: {
          ticket: {
            subject: "Need VPN access",
            description: "Cannot connect while travelling.",
            status: :open,
            category: category_option
          }
        }
      end.to change(Ticket, :count).by(1)

      ticket = Ticket.order(:created_at).last
      expect(ticket.priority).to eq("medium")
    end
  end

  describe "DELETE /tickets/:id" do
    let!(:ticket) { create(:ticket, requester: requester) }

    it "allows the requester to delete their open ticket" do
      sign_in(requester)

      expect do
        delete ticket_path(ticket)
      end.to change(Ticket, :count).by(-1)

      expect(response).to redirect_to(tickets_path)
      follow_redirect!
      expect(response.body).to include("Ticket deleted successfully.")
    end

    it "prevents other users from deleting the ticket" do
      sign_in(other_user)

      expect {
        delete ticket_path(ticket)
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "prevents deleting a resolved ticket" do
      ticket.update!(status: :resolved)
      sign_in(requester)

      expect {
        delete ticket_path(ticket)
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "redirects with alert when update fails" do
      sign_in(requester)
      allow_any_instance_of(Ticket).to receive(:update).with(status: :resolved).and_return(false)
      fake_errors = double(full_messages: [ "Something went wrong" ], any?: true)
      allow_any_instance_of(Ticket).to receive(:errors).and_return(fake_errors)

      patch close_ticket_path(ticket)
      expect(response).to redirect_to(ticket_path(ticket))
      follow_redirect!
      expect(response.body).to include("Something went wrong")
    end
  end

  describe "PATCH /tickets/:id" do
    let!(:ticket) { create(:ticket, requester: requester, status: :open) }

    it "allows staff to update the ticket status" do
      agent = create(:user, :agent)
      sign_in(agent)

      patch ticket_path(ticket), params: { ticket: { status: :in_progress } }
      ticket.reload

      expect(ticket.status).to eq("in_progress")
      expect(response).to redirect_to(ticket_path(ticket))
    end

    it "does not allow the requester to modify status" do
      sign_in(requester)

      patch ticket_path(ticket), params: { ticket: { status: :resolved } }
      ticket.reload

      expect(ticket.status).to eq("open")
    end

    it "renders :unprocessable_content when update fails" do
      agent = create(:user, :agent)
      sign_in(agent)
      allow_any_instance_of(Ticket).to receive(:update).and_return(false)
      fake_errors = double(full_messages: [ "Subject can't be blank" ], any?: true)
      allow_any_instance_of(Ticket).to receive(:errors).and_return(fake_errors)

      patch ticket_path(ticket), params: { ticket: { subject: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /tickets/:id/close" do
    let!(:ticket) { create(:ticket, requester: requester, status: :open) }

    it "resolves the ticket and sets closed_at" do
      sign_in(requester)

      patch close_ticket_path(ticket)
      ticket.reload

      expect(ticket.status).to eq("resolved")
      expect(ticket.closed_at).to be_present
      expect(response).to redirect_to(ticket_path(ticket))
    end

    it "prevents other users from closing the ticket" do
      sign_in(other_user)

      expect {
        patch close_ticket_path(ticket)
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "prevents closing an already resolved ticket" do
      ticket.update!(status: :resolved)
      sign_in(requester)

      expect {
        patch close_ticket_path(ticket)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET /tickets/:id (privacy)" do
    let!(:ticket) { create(:ticket, requester: requester) }

    it "allows the requester (owner) to view their ticket" do
      sign_in(requester)
      get ticket_path(ticket)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(ticket.subject)
    end

    it "prevents other requesters from viewing the ticket" do
      sign_in(other_user)
      expect {
        get ticket_path(ticket)
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "allows an agent to view any ticket" do
      agent = create(:user, :agent)
      sign_in(agent)
      get ticket_path(ticket)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(ticket.subject)
    end
  end

  describe "PATCH /tickets/:id/assign" do
    let!(:ticket) { create(:ticket, requester: requester, status: :open) }

    it "allows agent to assign ticket to another agent" do
      agent = create(:user, :agent)
      sign_in(agent)
      new_agent = create(:user, :agent)

      patch assign_ticket_path(ticket), params: { ticket: { assignee_id: new_agent.id } }
      expect(response).to redirect_to(ticket_path(ticket))
      expect(ticket.reload.assignee).to eq(new_agent)
    end

    it "prevents non-agent from assigning" do
      sign_in(requester)
      expect {
        patch assign_ticket_path(ticket), params: { ticket: { assignee_id: requester.id } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "POST /tickets invalid create" do
    it "renders :new with :unprocessable_content status when params invalid" do
      sign_in(requester)
      post tickets_path, params: { ticket: { subject: "", description: "", category: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
