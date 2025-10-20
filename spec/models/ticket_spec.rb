require 'rails_helper'

RSpec.describe Ticket, type: :model do
  it "is valid with a title and description" do
    ticket = Ticket.new(title: "Sample", description: "Sample description")
    expect(ticket).to be_valid
  end

  it "is invalid without a title" do
    ticket = Ticket.new(description: "No title")
    expect(ticket).not_to be_valid
  end

  it "is invalid without a description" do
    ticket = Ticket.new(title: "No description")
    expect(ticket).not_to be_valid
  end
end
