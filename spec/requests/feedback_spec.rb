require "rails_helper"

RSpec.describe "Ticket customer service feedback", type: :request do
  let(:requester) { create(:user, :requester) }
  let(:other_user) { create(:user, :requester) }

  # helper for logging in (Devise or your own auth)
  def sign_in(user)
    # adapt this to your auth system
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "PATCH /tickets/:id/rate" do
    let(:ticket) { create(:ticket, requester: requester, status: :resolved, customer_service_rating: nil) }

    context "as the requester" do
      before { sign_in(requester) }

      it "saves the rating and feedback" do
        patch rate_ticket_path(ticket), params: {
          ticket: {
            customer_service_rating: 5,
            customer_service_feedback: "Great support"
          }
        }

        expect(response).to redirect_to(ticket_path(ticket))
        follow_redirect!

        ticket.reload
        expect(ticket.customer_service_rating).to eq(5)
        expect(ticket.customer_service_feedback).to eq("Great support")
        expect(ticket.customer_service_rated_at).to be_present
      end

      it "does not allow rating if ticket is not resolved" do
        ticket.update!(status: :open)

        patch rate_ticket_path(ticket), params: {
          ticket: { customer_service_rating: 4 }
        }

        ticket.reload
        expect(ticket.customer_service_rating).to be_nil
        expect(response).to redirect_to(ticket_path(ticket)) # or wherever you redirect on failure
      end
    end

    context "as a different user" do
      before { sign_in(other_user) }

      it "does not allow rating someone else's ticket" do
        patch rate_ticket_path(ticket), params: {
          ticket: { customer_service_rating: 3, customer_service_feedback: "OK" }
        }

        ticket.reload
        expect(ticket.customer_service_rating).to be_nil
        # depending on your policy, you may get 302 to root, or 403, etc.
        expect(response).to have_http_status(:redirect).or have_http_status(:forbidden)
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        patch rate_ticket_path(ticket), params: {
          ticket: { customer_service_rating: 5 }
        }

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
