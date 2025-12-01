require 'rails_helper'

RSpec.describe 'Personal Dashboard', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /dashboard' do
    it 'returns a successful response' do
  get personal_dashboard_path
      expect(response).to have_http_status(:success)
    end

    it 'displays "My Open Tickets" count' do
      requester = create(:user)
      create(:ticket, assignee: user, status: :open, requester: requester)
      create(:ticket, assignee: user, status: :open, requester: requester)
      create(:ticket, assignee: user, status: :resolved, closed_at: Time.current, requester: requester)

  get personal_dashboard_path
      expect(assigns(:open_tickets_count)).to eq(2)
      expect(response.body).to include('2') # Check the count appears in the rendered view
    end

    it 'displays 5 most recently updated tickets section' do
      requester = create(:user)
      7.times do
        create(:ticket, assignee: user, status: :open, requester: requester)
      end

  get personal_dashboard_path
      expect(assigns(:recent_tickets).count).to eq(5)
      expect(response.body).to include('5 Most Recently Updated Tickets')
    end

    it 'renders the dashboard template' do
  get personal_dashboard_path
  expect(response).to render_template(:dashboard)
    end

    it 'includes ticket card links for clicking through to show pages' do
      requester = create(:user)
      ticket = create(:ticket, assignee: user, status: :open, subject: 'Test Bug', requester: requester)

  get personal_dashboard_path
  expect(response.body).to include(ticket_path(ticket))
      expect(response.body).to include('Test Bug')
    end

    it 'displays tickets grouped by status' do
      requester = create(:user)
      create(:ticket, assignee: user, status: :open, requester: requester)
      create(:ticket, assignee: user, status: :in_progress, requester: requester)
      create(:ticket, assignee: user, status: :resolved, closed_at: Time.current, requester: requester)

  get personal_dashboard_path
  expect(response.body).to include('Open (1)')
      expect(response.body).to include('In Progress (1)')
      expect(response.body).to include('Resolved (1)')
    end

    it 'only shows tickets assigned to the current user' do
      requester1 = create(:user)
      requester2 = create(:user)
      user2 = create(:user)
      user_ticket = create(:ticket, assignee: user, status: :open, subject: 'My Ticket', requester: requester1)
      other_ticket = create(:ticket, assignee: user2, status: :open, subject: 'Other Ticket', requester: requester2)

  get personal_dashboard_path
  expect(response.body).to include('My Ticket')
      expect(response.body).not_to include('Other Ticket')
    end

    it 'shows no tickets message when user has no tickets' do
  get personal_dashboard_path
  expect(response.body).to include('No tickets assigned to you yet.')
    end
  end
end
