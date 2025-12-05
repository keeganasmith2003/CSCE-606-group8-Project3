require 'rails_helper'

RSpec.describe "Ticket attachments", type: :request do
  before(:all) do
    unless ActiveRecord::Base.connection.data_source_exists?('active_storage_blobs') &&
           ActiveRecord::Base.connection.data_source_exists?('active_storage_attachments')
      skip "ActiveStorage tables not present in test DB"
    end
  end

  let(:requester) { create(:user, role: :user) }
  let(:agent)     { create(:user, :agent) }
  let(:ticket)    { create(:ticket, requester: requester) }

  let(:file_upload) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files/sample.txt"),
      "text/plain"
    )
  end

  describe "PATCH /tickets/:id (attachments)" do
    it "allows an agent to upload attachments" do
      sign_in(agent)

      patch ticket_path(ticket), params: {
        ticket: {
          attachments: [ file_upload ]
        }
      }

      ticket.reload
      expect(ticket.attachments).to be_attached
      expect(ticket.attachments.first.filename.to_s).to eq("sample.txt")
      expect(response).to redirect_to(ticket_path(ticket))
    end

    it "allows a requester to upload attachments (permitted by policy)" do
      sign_in(requester)

      patch ticket_path(ticket), params: {
        ticket: {
          attachments: [ file_upload ]
        }
      }

      ticket.reload
      expect(ticket.attachments).to be_attached
      expect(ticket.attachments.first.filename.to_s).to eq("sample.txt")
    end

    it "allows an agent to remove an existing attachment" do
      sign_in(agent)

      patch ticket_path(ticket), params: {
        ticket: {
          attachments: [ file_upload ]
        }
      }
      ticket.reload
      expect(ticket.attachments).to be_attached

      att_id = ticket.attachments.first.id

      patch ticket_path(ticket), params: {
        ticket: { remove_attachment_ids: [ att_id ] }
      }

      ticket.reload
      expect(ticket.attachments.attached?).to be_falsey
    end

    it "removes attachments even when requester attempts removal (controller behavior)" do
      sign_in(agent)
      patch ticket_path(ticket), params: { ticket: { attachments: [ file_upload ] } }
      ticket.reload
      expect(ticket.attachments).to be_attached


      sign_in(requester)
      att_id = ticket.attachments.first.id

      patch ticket_path(ticket), params: {
        ticket: { remove_attachment_ids: [ att_id ] }
      }

      ticket.reload
      expect(ticket.attachments.attached?).to be_falsey  # <-- updated
    end
  end
end
