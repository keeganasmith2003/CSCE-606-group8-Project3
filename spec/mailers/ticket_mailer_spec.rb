require "rails_helper"

RSpec.describe TicketMailer, type: :mailer do
  describe "ticket_updated_email" do
    # Create a user and ticket to test with
    let(:requester) { User.create!(name: "Alice", email: "alice@test.com", role: :user, provider: "google", uid: "123") }
    let(:ticket) {
      Ticket.create!(
        subject: "Printer Issue",
        description: "Paper jam",
        status: :open,
        priority: :medium,
        category: "Technical Issue",
        requester: requester
      )
    }

    # Trigger the email
    let(:mail) { TicketMailer.with(ticket: ticket).ticket_updated_email }

    it "renders the headers" do
      expect(mail.subject).to eq("[Ticket ##{ticket.id}] Update: Printer Issue")
      expect(mail.to).to eq([ "alice@test.com" ])
      # Update this match the 'default from' in your app/mailers/application_mailer.rb
      # expect(mail.from).to eq(["postmaster@sandbox....mailgun.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Printer Issue")
      expect(mail.body.encoded).to match("Alice")
      expect(mail.body.encoded).to match("OPEN")
    end
  end
end
