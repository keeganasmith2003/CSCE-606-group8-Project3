require 'rails_helper'

RSpec.describe "tickets/index", type: :view do
  let(:requester) { FactoryBot.create(:user, :requester) }
  before(:each) do
    assign(:tickets, [
      Ticket.create!(
        subject: "Title",
        description: "MyText",
        priority: :low,
        requester: requester,
        status: :pending
      ),
      Ticket.create!(
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
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end
