require "rails_helper"

RSpec.describe "Tickets member routes rescues", type: :request do
  let(:agent) { create(:user, :agent) }
  let(:requester) { create(:user, :requester) }
  let(:ticket) { create(:ticket, requester: requester) }

  before { sign_in(agent) }

  it "approve route shows alert when approve! raises" do
    allow_any_instance_of(Ticket).to receive(:approve!).and_raise("oops")
    patch approve_ticket_path(ticket)
    expect(response).to redirect_to(ticket_path(ticket))
    follow_redirect!
    expect(response.body).to include("Could not approve ticket")
  end

  it "reject route shows alert when reject! raises" do
    allow_any_instance_of(Ticket).to receive(:reject!).and_raise("bad")
    patch reject_ticket_path(ticket), params: { ticket: { approval_reason: "x" } }
    expect(response).to redirect_to(ticket_path(ticket))
    follow_redirect!
    expect(response.body).to include("Could not reject ticket")
  end
end
