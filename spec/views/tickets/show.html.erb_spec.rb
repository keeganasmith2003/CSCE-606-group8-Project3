require 'rails_helper'

RSpec.describe "tickets/show", type: :view do
  let(:requester) { FactoryBot.create(:user, :requester) }
  let(:ticket_policy) { instance_double(TicketPolicy, close?: false, destroy?: false) }
  let(:comment_policy) { instance_double(CommentPolicy, create?: false) }

  before(:each) do
    ticket = create(
      :ticket,
      subject: "Title",
      description: "MyText",
      priority: :low,
      requester: requester,
      status: :pending
    )

    assign(:ticket, ticket)
    assign(:comments, [])
    assign(:comment, build(:comment, ticket: ticket, author: requester))

    ticket_policy_double = ticket_policy
    comment_policy_double = comment_policy
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

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
  end
end
