require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  it "sets the default from address" do
    expect(described_class.default[:from]).to eq("from@example.com")
  end

  it "uses the mailer layout" do
    # Rails stores the layout name on the class
    expect(described_class._layout).to eq("mailer")
  end
end
