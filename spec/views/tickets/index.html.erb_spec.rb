require 'rails_helper'

RSpec.describe "tickets/index", type: :view do
  let(:requester) { FactoryBot.create(:user, :requester) }
  let(:policy_double) { instance_double(TicketPolicy, destroy?: false) }

  before(:each) do
    policy = policy_double
    view.singleton_class.send(:define_method, :policy) { |_record| policy }

    assign(:tickets, [
      create(
        :ticket,
        subject: "Title",
        description: "MyText",
        priority: :low,
        requester: requester,
        status: :in_progress
      ),
      create(
        :ticket,
        subject: "Title",
        description: "MyText",
        priority: :low,
        requester: requester,
        status: :on_hold
      )
    ])

    # NEW: filter options expected by the index view
    assign(:status_options, Ticket.statuses.keys)
    assign(:approval_status_options, Ticket.approval_statuses.keys)
    assign(:category_options, Ticket::CATEGORY_OPTIONS)
    assign(:assignee_options, [])
  end

  it "renders a list of tickets" do
    render

    # Still ensure both ticket titles are rendered as links
    assert_select 'h2>a', text: "Title", count: 2

    # New layout: one .ticket-card per ticket
    assert_select '.ticket-card', count: 2

    # We no longer render "Status:" in <p> tags, but we DO render status badges
    assert_select '.status-badge', minimum: 2

    # Category is also rendered as a badge, not in a <p>
    # If you want to be strict, you can assert that at least one badge contains a category name:
    # assert_select '.status-badge', text: Ticket::CATEGORY_OPTIONS.first, minimum: 1
  end
end
