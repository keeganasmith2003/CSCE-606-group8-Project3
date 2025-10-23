require 'rails_helper'

RSpec.describe "tickets/edit", type: :view do
  let(:requester) { FactoryBot.create(:user, :requester) }
  let(:ticket) do
    create(
      :ticket,
      subject: "MyString",
      description: "MyText",
      priority: :low,
      requester: requester,
      status: :pending
    )
  end

  before(:each) do
    assign(:ticket, ticket)
  end

  it "renders the edit ticket form" do
    render

    assert_select "form[action=?][method=?]", ticket_path(ticket), "post" do
      assert_select "input[name=?]", "ticket[subject]"

      assert_select "textarea[name=?]", "ticket[description]"
    end
  end
end
