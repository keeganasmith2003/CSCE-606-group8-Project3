require "rails_helper"

RSpec.describe TicketsController, type: :request do
  let(:requester) { create(:user, role: :user) }
  let(:agent)     { create(:user, role: :staff) }
  let(:admin)     { create(:user, role: :sysadmin) }
  let(:team)      { create(:team) }
  let(:ticket)    { create(:ticket, requester: requester, team: team) }

  before do
    team.members << agent
  end

  def sign_in(user)
    allow_any_instance_of(ApplicationController)
      .to receive(:authenticate_user!)
      .and_return(true)
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end

  # -----------------------------
  # INDEX
  # -----------------------------
  describe "GET /tickets" do
    before { sign_in(agent) }

    it "returns 200" do
      get tickets_path
      expect(response).to have_http_status(:ok)
    end

    it "applies filters (status)" do
      create(:ticket, status: :open, requester: requester)
      create(:ticket, status: :resolved, requester: requester)

      get tickets_path, params: { status: "resolved" }

      expect(assigns(:tickets).pluck(:status)).to eq([ "resolved" ])
    end
  end

  # -----------------------------
  # MINE
  # -----------------------------
  describe "GET /tickets/mine" do
    before { sign_in(agent) }

    it "returns tickets assigned to the user or their team" do
      t1 = create(:ticket, assignee: agent, requester: requester)
      t2 = create(:ticket, team: team, requester: requester)
      t3 = create(:ticket, requester: requester) # not visible

      get mine_tickets_path

      expect(assigns(:tickets)).to include(t1, t2)
      expect(assigns(:tickets)).not_to include(t3)
    end
  end

  # -----------------------------
  # SHOW
  # -----------------------------
  describe "GET /tickets/:id" do
    before { sign_in(requester) }

    it "shows only public comments for requester" do
      public_comment = create(:comment, ticket: ticket, visibility: :public)
      private_comment = create(:comment, ticket: ticket, visibility: :internal)

      get ticket_path(ticket)

      expect(assigns(:comments)).to include(public_comment)
      expect(assigns(:comments)).not_to include(private_comment)
    end
  end

  # -----------------------------
  # CREATE
  # -----------------------------
  describe "POST /tickets" do
    before { sign_in(requester) }

    let(:params) do
      {
        ticket: {
          subject: "Login issue",
          description: "Cannot login",
          category: "Technical Issue",
          priority: "medium"
        }
      }
    end

    it "creates a ticket" do
      expect {
        post tickets_path, params: params
      }.to change(Ticket, :count).by(1)
    end

    it "auto-assigns team based on category" do
      support_team = create(:team, name: "Support")

      post tickets_path, params: params

      expect(Ticket.last.team).to eq(support_team)
    end
  end

  # -----------------------------
  # UPDATE
  # -----------------------------
  describe "PATCH /tickets/:id" do
    before { sign_in(agent) }

    it "updates basic attributes" do
      patch ticket_path(ticket), params: { ticket: { subject: "Updated" } }
      expect(ticket.reload.subject).to eq("Updated")
    end

    it "approves ticket when approval parameter is given" do
      patch ticket_path(ticket), params: { ticket: { approval_status: "approved" } }
      expect(ticket.reload.approval_status).to eq("approved")
    end

    it "rejects ticket with reason" do
      patch ticket_path(ticket), params: {
        ticket: { approval_status: "rejected", approval_reason: "Invalid" }
      }
      expect(ticket.reload.approval_status).to eq("rejected")
      expect(ticket.reload.approval_reason).to eq("Invalid")
    end
  end


  # -----------------------------
  # REJECT
  # -----------------------------
  describe "PATCH /tickets/:id/reject" do
    before { sign_in(agent) }

    it "rejects ticket with reason" do
      patch reject_ticket_path(ticket),
            params: { approval_reason: "No resources" }

      expect(ticket.reload.approval_status).to eq("rejected")
    end
  end

  # -----------------------------
  # ASSIGN
  # -----------------------------
  describe "PATCH /tickets/:id/assign" do
    before { sign_in(agent) }

    it "updates team and assignee" do
      patch assign_ticket_path(ticket), params: {
        ticket: { team_id: team.id, assignee_id: agent.id }
      }

      expect(ticket.reload.team_id).to eq(team.id)
      expect(ticket.reload.assignee_id).to eq(agent.id)
    end

    it "rejects assignee if not in team" do
      outsider = create(:user, role: :staff)

      patch assign_ticket_path(ticket), params: {
        ticket: { team_id: team.id, assignee_id: outsider.id }
      }

      expect(ticket.reload.assignee_id).to be_nil
    end
  end

  # -----------------------------
  # BOARD
  # -----------------------------
  describe "GET /tickets/board" do
    before { sign_in(agent) }

    it "returns 200 and groups tickets" do
      create(:ticket, status: :open, requester: requester)
      get board_tickets_path
      expect(response).to have_http_status(:ok)
      expect(assigns(:tickets_by_status)["open"]).not_to be_empty
    end
  end

  describe "POST /tickets/bulk_actions" do
    let!(:ticket1) { create(:ticket, status: :open, requester: requester, team: team) }
    let!(:ticket2) { create(:ticket, status: :open, requester: requester, team: team) }
    let!(:ticket3) { create(:ticket, status: :open, requester: requester) } # outside team, just to ensure not all are touched

    context "as staff/agent" do
      before { sign_in(agent) }

      it "closes selected tickets" do
        post bulk_actions_tickets_path, params: {
          bulk_action: "close",
          ticket_ids: [ ticket1.id, ticket2.id ]
        }

        expect(ticket1.reload.status).to eq("resolved")
        expect(ticket2.reload.status).to eq("resolved")
        expect(ticket1.closed_at).not_to be_nil
        expect(ticket2.closed_at).not_to be_nil

        # untouched
        expect(ticket3.reload.status).to eq("open")
      end

      it "deletes selected tickets" do
        expect {
          post bulk_actions_tickets_path, params: {
            bulk_action: "delete",
            ticket_ids: [ ticket1.id, ticket2.id ]
          }
        }.to change(Ticket, :count).by(-2)

        expect(Ticket.exists?(ticket1.id)).to be_falsey
        expect(Ticket.exists?(ticket2.id)).to be_falsey
        expect(Ticket.exists?(ticket3.id)).to be_truthy
      end

      it "does nothing when no ticket_ids are provided" do
        expect {
          post bulk_actions_tickets_path, params: {
            bulk_action: "close"
          }
        }.not_to change(Ticket, :count)

        expect(ticket1.reload.status).to eq("open")
        expect(ticket2.reload.status).to eq("open")
        expect(response).to redirect_to(tickets_path)
      end

      it "does nothing when bulk_action is missing" do
        expect {
          post bulk_actions_tickets_path, params: {
            ticket_ids: [ ticket1.id, ticket2.id ]
          }
        }.not_to change { [ ticket1.reload.status, ticket2.reload.status ] }

        expect(response).to redirect_to(tickets_path)
      end
    end

    context "as regular requester (user)" do
      before { sign_in(requester) }

      it "raises Pundit::NotAuthorizedError" do
        expect {
          post bulk_actions_tickets_path, params: {
            bulk_action: "close",
            ticket_ids: [ ticket1.id ]
          }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "as admin" do
      before { sign_in(admin) }

      it "can perform bulk deletes" do
        expect {
          post bulk_actions_tickets_path, params: {
            bulk_action: "delete",
            ticket_ids: [ ticket1.id, ticket2.id ]
          }
        }.to change(Ticket, :count).by(-2)
      end
    end
  end
end
