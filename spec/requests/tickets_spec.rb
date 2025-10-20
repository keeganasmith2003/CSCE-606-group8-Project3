# spec/requests/tickets_spec.rb
require 'rails_helper'

RSpec.describe "Tickets", type: :request do
  let!(:ticket) { Ticket.create!(title: "Bug Report", description: "App crashes") }

  describe "GET /index" do
    it "renders a successful response" do
      get tickets_path
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get ticket_path(ticket)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_ticket_path(ticket)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_params) { { ticket: { title: "New Ticket", description: "Details here" } } }

      it "creates a new Ticket" do
        expect {
          post tickets_path, params: valid_params
        }.to change(Ticket, :count).by(1)
      end

      it "redirects to the created ticket" do
        post tickets_path, params: valid_params
        expect(response).to redirect_to(ticket_path(Ticket.last))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { ticket: { title: "", description: "" } } }

      it "does not create a new Ticket" do
        expect {
          post tickets_path, params: invalid_params
        }.not_to change(Ticket, :count)
      end

      it "renders the 'new' template with status 422" do
        post tickets_path, params: invalid_params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_update) { { ticket: { description: "Updated description" } } }

      it "updates the ticket" do
        patch ticket_path(ticket), params: valid_update
        ticket.reload
        expect(ticket.description).to eq("Updated description")
      end

      it "redirects to the ticket" do
        patch ticket_path(ticket), params: valid_update
        expect(response).to redirect_to(ticket_path(ticket))
      end
    end

    context "with invalid parameters" do
      let(:invalid_update) { { ticket: { title: "" } } }

      it "does not update the ticket" do
        original_title = ticket.title
        patch ticket_path(ticket), params: invalid_update
        ticket.reload
        expect(ticket.title).to eq(original_title)
      end

      it "renders the 'edit' template with status 422" do
        patch ticket_path(ticket), params: invalid_update
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested ticket" do
      expect {
        delete ticket_path(ticket)
      }.to change(Ticket, :count).by(-1)
    end

    it "redirects to the tickets list" do
      delete ticket_path(ticket)
      expect(response).to redirect_to(tickets_path)
    end
  end
end
