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
        status: :pending
      ),
      create(
        :ticket,
        subject: "Title",
        description: "MyText",
        priority: :low,
        requester: requester,
        status: :pending
      )
    ])
  end

  it "renders a list of tickets" do
    render
    assert_select 'h2>a', text: "Title", count: 2
    assert_select 'p', text: /Status:/, count: 2
    assert_select 'p', text: /Category:/, count: 2
  end
end
