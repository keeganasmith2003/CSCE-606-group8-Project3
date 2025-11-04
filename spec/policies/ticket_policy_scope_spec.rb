require "rails_helper"

RSpec.describe TicketPolicy::Scope do
  let!(:admin) { create(:user, :admin) }
  let!(:requester1) { create(:user, :requester) }
  let!(:requester2) { create(:user, :requester) }
  let!(:t1) { create(:ticket, requester: requester1) }
  let!(:t2) { create(:ticket, requester: requester2) }

  it "returns all for admin" do
    scope = described_class.new(admin, Ticket.all).resolve
    expect(scope).to match_array([ t1, t2 ])
  end

  it "returns only own tickets for requester" do
    scope = described_class.new(requester1, Ticket.all).resolve
    expect(scope).to match_array([ t1 ])
  end
end
