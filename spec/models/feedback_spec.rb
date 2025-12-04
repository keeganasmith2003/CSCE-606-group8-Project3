require "rails_helper"

RSpec.describe Ticket, type: :model do
  let(:requester) { create(:user, :requester) }
  let(:other_user) { create(:user, :requester) }

  describe "#customer_service_rated?" do
    it "returns false when no rating is present" do
      ticket = create(:ticket, requester: requester, customer_service_rating: nil)

      expect(ticket.customer_service_rated?).to eq(false)
    end

    it "returns true when a rating is present" do
      ticket = create(:ticket, requester: requester, customer_service_rating: 4)

      expect(ticket.customer_service_rated?).to eq(true)
    end
  end

  describe "#ratable_by?" do
    let(:ticket) { create(:ticket, requester: requester, status: :resolved, customer_service_rating: nil) }

    it "returns false when user is nil" do
      expect(ticket.ratable_by?(nil)).to eq(false)
    end

    it "returns false when ticket is not resolved" do
      ticket.update!(status: :open)

      expect(ticket.ratable_by?(requester)).to eq(false)
    end

    it "returns false when ticket already has a rating" do
      ticket.update!(customer_service_rating: 5)

      expect(ticket.ratable_by?(requester)).to eq(false)
    end

    it "returns false when user is not the requester" do
      expect(ticket.ratable_by?(other_user)).to eq(false)
    end

    it "returns true when user is the requester, ticket is resolved, and not yet rated" do
      ticket.update!(status: :resolved, customer_service_rating: nil)

      expect(ticket.ratable_by?(requester)).to eq(true)
    end
  end
end
