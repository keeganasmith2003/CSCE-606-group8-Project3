# spec/views/tickets/show_feedback_spec.rb
require "rails_helper"

RSpec.describe "tickets/show", type: :view do
  let(:requester) { create(:user, :requester) }
  let(:ticket_policy) do
    instance_double(
      TicketPolicy,
      assign?:        false,
      close?:         false,
      destroy?:       false,
      change_status?: false,
      edit?:          true,
      update?:        true # 👈 ADD THIS
    )
  end
  let(:comment_policy) { instance_double(CommentPolicy, create?: false) }

  before do
    @ticket = create(
      :ticket,
      subject: "Title",
      description: "MyText",
      priority: :low,
      requester: requester,
      status: :resolved,
      customer_service_rating: nil
    )

    assign(:ticket, @ticket)
    assign(:comments, [])
    assign(:comment, build(:comment, ticket: @ticket, author: requester))

    ticket_policy_double  = ticket_policy
    comment_policy_double = comment_policy

    # current_user for the view
    current = requester
    view.singleton_class.send(:define_method, :current_user) { current }

    # policy(record) for the view
    view.singleton_class.send(:define_method, :policy) do |record|
      case record
      when Ticket
        ticket_policy_double
      when Comment
        comment_policy_double
      else
        raise "Unexpected record: #{record.inspect}"
      end
    end
  end

  it "shows the rating form when the ticket is ratable by the current user" do
    allow_any_instance_of(Ticket).to receive(:ratable_by?).with(requester).and_return(true)

    render

    expect(rendered).to include("Customer Feedback")
    expect(rendered).to include("How was the customer service you received on this ticket?")
    expect(rendered).to have_css("div.star-rating")
    expect(rendered).to include(rate_ticket_path(@ticket))
  end

  it "shows the saved rating and feedback when already rated" do
    @ticket.update!(
      customer_service_rating: 4,
      customer_service_feedback: "Good but slow",
      customer_service_rated_at: Time.current
    )

    render

    expect(rendered).to include("Customer Feedback")
    expect(rendered).to include("Good but slow")
    expect(rendered).to include("★")
  end

  it "shows waiting message for requester when unresolved" do
    @ticket.update!(status: :open, customer_service_rating: nil)
    allow_any_instance_of(Ticket).to receive(:ratable_by?).and_return(false)

    render

    expect(rendered).to include("Customer Feedback")
    expect(rendered).to match(/You can rate this ticket after it has been resolved|No customer feedback has been submitted yet/)
  end
end
