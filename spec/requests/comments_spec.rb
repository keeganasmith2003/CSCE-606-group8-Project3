require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:ticket) { create(:ticket) }
  let(:requester) { ticket.requester }
  let(:agent) { create(:user, role: :staff) }

  describe "POST /tickets/:ticket_id/comments" do
    it "allows the requester to add a public comment" do
      sign_in(requester)

      expect do
        post ticket_comments_path(ticket), params: {
          comment: {
            body: "Additional info from the requester."
          }
        }
      end.to change(Comment, :count).by(1)

      comment = Comment.order(:created_at).last
      expect(comment.visibility).to eq("public")
      expect(comment.body).to include("Additional info")
      expect(response).to redirect_to(ticket_path(ticket))
    end

    it "ignores internal visibility submitted by requester" do
      sign_in(requester)

      post ticket_comments_path(ticket), params: {
        comment: {
          body: "Trying to sneak an internal note.",
          visibility: :internal
        }
      }

      expect(Comment.order(:created_at).last.visibility).to eq("public")
    end

    it "allows an agent to create an internal comment" do
      sign_in(agent)

      expect do
        post ticket_comments_path(ticket), params: {
          comment: {
            body: "Internal triage details.",
            visibility: :internal
          }
        }
      end.to change(Comment, :count).by(1)

      expect(Comment.order(:created_at).last.visibility).to eq("internal")
    end

    it "prevents commenting on a resolved ticket" do
      ticket.update!(status: :resolved)
      sign_in(requester)

      expect {
        post ticket_comments_path(ticket), params: { comment: { body: "Closing remark" } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "on save failure sets flash alert and redirects with :unprocessable_content" do
      sign_in(agent) # ensure policy passes

      allow_any_instance_of(Comment).to receive(:save).and_return(false)
      fake_errors = double(full_messages: [ "Body can't be blank" ])
      allow_any_instance_of(Comment).to receive(:errors).and_return(fake_errors)

      post ticket_comments_path(ticket), params: { comment: { body: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to include("Body can't be blank")
    end
  end
end
