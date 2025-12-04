# spec/views/tickets/index_feedback_spec.rb
require "rails_helper"

RSpec.describe "tickets/index", type: :view do
  let(:requester) { create(:user, :requester) }

  before do
    # Make a simple ticket policy double used for all tickets here
    ticket_policy_double = instance_double(TicketPolicy)
    allow(ticket_policy_double).to receive(:destroy?).and_return(false)

    # Define policy(record) for this view instance
    view.singleton_class.send(:define_method, :policy) do |record|
      ticket_policy_double
    end
  end

  it "shows a rating badge for rated tickets" do
    rated_ticket = create(
      :ticket,
      subject: "VPN performance",
      description: "Slow connection",
      requester: requester,
      status: :resolved,
      customer_service_rating: 3,
      customer_service_feedback: "OK"
    )

    unrated_ticket = create(
      :ticket,
      subject: "New feature request",
      description: "Please add X",
      requester: requester,
      status: :open,
      customer_service_rating: nil
    )

    assign(:tickets, [rated_ticket, unrated_ticket])
    assign(:status_options, Ticket.statuses.keys)
    assign(:approval_status_options, Ticket.approval_statuses.keys)
    assign(:category_options, [])
    assign(:assignee_options, [])

    render

    # Rated ticket shows stars (adjust string to your render_star_rating implementation)
    expect(rendered).to match(/VPN performance/)
    expect(rendered).to include("★★★") # or "★★★☆☆" depending on your helper

    # Unrated ticket still appears, but without a rating badge
    expect(rendered).to match(/New feature request/)
  end
end
