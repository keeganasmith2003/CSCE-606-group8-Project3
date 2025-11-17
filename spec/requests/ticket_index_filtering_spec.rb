# spec/requests/ticket_index_filtering_spec.rb
require "rails_helper"

RSpec.describe "Tickets index filtering", type: :request do
  let(:agent)       { create(:user, :agent) }
  let(:other_agent) { create(:user, :agent) }

  # Pull valid categories from the model's inclusion validator so we don't
  # hardcode invalid values like "Billing" and "Tech".
  let(:valid_categories) do
    inclusion_validator = Ticket.validators_on(:category)
                                 .grep(ActiveModel::Validations::InclusionValidator)
                                 .first

    Array(inclusion_validator&.options&.fetch(:in, []))
  end

  let(:category_one)  { valid_categories[0] || "General" }
  let(:category_two)  { valid_categories[1] || valid_categories[0] || "General" }

  # Common tickets visible in /tickets
  let!(:open_cat1_pending) do
    create(
      :ticket,
      status: :open,
      category: category_one,
      subject: "Cat1 open pending",
      description: "Problem with invoice",
      assignee: agent,
      approval_status: :pending
    )
  end

  let!(:resolved_cat2_approved) do
    create(
      :ticket,
      status: :resolved,
      category: category_two,
      subject: "Cat2 resolved approved",
      description: "The app crashes when opening",
      assignee: other_agent,
      approval_status: :approved
    )
  end

  let!(:open_cat2_rejected) do
    create(
        :ticket,
        status: :open,
        category: category_two,
        subject: "Cat2 open rejected",
        description: "Needs replacement",
        assignee: agent,
        approval_status: :rejected,
        approval_reason: "Not approved for test purposes"
    )
  end


  before do
    sign_in(agent) # ensure index is authorized
  end

  describe "GET /tickets with filters" do
    it "filters by status" do
      get tickets_path, params: { status: "open" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(open_cat1_pending.subject)
      expect(response.body).to include(open_cat2_rejected.subject)
      expect(response.body).not_to include(resolved_cat2_approved.subject)
    end

    it "filters by category" do
      get tickets_path, params: { category: category_one }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(open_cat1_pending.subject)
      expect(response.body).not_to include(resolved_cat2_approved.subject)
      expect(response.body).not_to include(open_cat2_rejected.subject)
    end

    it "filters by assignee_id" do
      get tickets_path, params: { assignee_id: agent.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(open_cat1_pending.subject)
      expect(response.body).to include(open_cat2_rejected.subject)
      expect(response.body).not_to include(resolved_cat2_approved.subject)
    end

    it "filters by approval_status" do
      get tickets_path, params: { approval_status: "approved" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(resolved_cat2_approved.subject)
      expect(response.body).not_to include(open_cat1_pending.subject)
      expect(response.body).not_to include(open_cat2_rejected.subject)
    end

    it "applies text search (subject + description), case-insensitive" do
      # Search term appears only in resolved_cat2_approved
      resolved_cat2_approved.update!(subject: "App crash on login")

      get tickets_path, params: { q: "crash" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(resolved_cat2_approved.subject)
      expect(response.body).not_to include(open_cat1_pending.subject)
      expect(response.body).not_to include(open_cat2_rejected.subject)

      # Case-insensitivity check
      get tickets_path, params: { q: "CRASH" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(resolved_cat2_approved.subject)
    end

    it "combines multiple filters together" do
      # open + category_two + rejected should only match open_cat2_rejected
      get tickets_path, params: {
        status:          "open",
        category:        category_two,
        approval_status: "rejected"
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(open_cat2_rejected.subject)
      expect(response.body).not_to include(open_cat1_pending.subject)
      expect(response.body).not_to include(resolved_cat2_approved.subject)
    end
  end

  describe "GET /tickets/mine" do
    let!(:mine_assigned) do
      create(
        :ticket,
        status: :open,
        category: category_two,
        subject: "Assigned to current agent",
        description: "Details",
        assignee: agent,
        approval_status: :pending
      )
    end

    let!(:not_mine) do
      create(
        :ticket,
        status: :open,
        category: category_two,
        subject: "Assigned to other agent",
        description: "Details",
        assignee: other_agent,
        approval_status: :pending
      )
    end

    it "shows only tickets assigned to the current user (no team membership case)" do
      get mine_tickets_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(mine_assigned.subject)
      expect(response.body).not_to include(not_mine.subject)
    end

    it "applies the same filters on /mine as /tickets" do
      get mine_tickets_path, params: { status: "open", category: category_two }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(mine_assigned.subject)
      expect(response.body).not_to include(not_mine.subject)
      # And still not show tickets outside the mine scope
      expect(response.body).not_to include(open_cat1_pending.subject)
      expect(response.body).not_to include(resolved_cat2_approved.subject)
    end

    it "applies search filter on /mine" do
      mine_assigned.update!(subject: "FOOBAR unique subject")

      get mine_tickets_path, params: { q: "foobar" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(mine_assigned.subject)
      expect(response.body).not_to include(not_mine.subject)
    end
  end
end
