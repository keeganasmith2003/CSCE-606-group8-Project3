require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  it "sets the default from address" do
    expect(described_class.default[:from]).to eq("Support Team <csce606Project3@sandbox730d2528719d4c12aaf0f9c0b1f35576.mailgun.org")
  end

  it "uses the mailer layout" do
    # Rails stores the layout name on the class
    expect(described_class._layout).to eq("mailer")
  end
end
