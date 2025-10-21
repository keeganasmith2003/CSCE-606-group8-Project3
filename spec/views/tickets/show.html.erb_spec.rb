require 'rails_helper'

RSpec.describe "tickets/show", type: :view do
  let(:requester) { FactoryBot.create(:user, :requester) }
  before(:each) do
    assign(:ticket, Ticket.create!(
      subject: "Title",
      description: "MyText",
      priority: :low,
      requester: requester,
      status: :pending
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
  end
end
