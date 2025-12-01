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

    # filter options expected by the index view
    assign(:status_options, Ticket.statuses.keys)
    assign(:approval_status_options, Ticket.approval_statuses.keys)
    assign(:category_options, Ticket::CATEGORY_OPTIONS)
    assign(:assignee_options, [])
  end

  it "renders a list of tickets" do
    render
    assert_select 'h2.ticket-card__title>a', text: "Title", count: 2
    assert_select 'p.ticket-card__excerpt', count: 2
  end
end
