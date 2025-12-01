require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe '.completion_rate_by_week' do
    let(:user) { create(:user) }
    let(:requester) { create(:user) }

    it 'returns labels and data keys' do
      result = Ticket.completion_rate_by_week(user, 30)
      expect(result).to have_key(:labels)
      expect(result).to have_key(:data)
      expect(result[:labels]).to be_an(Array)
      expect(result[:data]).to be_an(Array)
    end

    it 'counts resolved tickets for a user in the last 30 days' do
      create(:ticket, assignee: user, status: :resolved, closed_at: 1.week.ago)
      create(:ticket, assignee: user, status: :resolved, closed_at: 2.weeks.ago)
      create(:ticket, assignee: user, status: :open)

      result = Ticket.completion_rate_by_week(user, 30)
      expect(result[:data].sum).to eq(2)
    end

    it 'ignores resolved tickets outside the window' do
      create(:ticket, assignee: user, status: :resolved, closed_at: 45.days.ago)
      create(:ticket, assignee: user, status: :resolved, closed_at: 1.week.ago)

      result = Ticket.completion_rate_by_week(user, 30)
      expect(result[:data].sum).to eq(1)
    end

    it 'includes all statuses when user is nil' do
      create(:ticket, status: :resolved, closed_at: 1.week.ago)
      create(:ticket, assignee: user, status: :resolved, closed_at: 2.weeks.ago)

      result = Ticket.completion_rate_by_week(nil, 30)
      expect(result[:data].sum).to eq(2)
    end
  end

  describe '.tickets_by_category' do
    it 'returns a hash of categories and counts' do
      create(:ticket, category: 'Technical Issue')
      create(:ticket, category: 'Technical Issue')
      create(:ticket, category: 'Feature Request')

      result = Ticket.tickets_by_category
      expect(result).to be_a(Hash)
      expect(result['Technical Issue']).to eq(2)
      expect(result['Feature Request']).to eq(1)
    end

    it 'returns empty hash when no tickets exist' do
      result = Ticket.tickets_by_category
      expect(result).to be_a(Hash)
    end
  end

  describe '.average_resolution_time' do
    it 'returns average resolution time in hours' do
      ticket1 = create(:ticket, status: :resolved, created_at: 5.hours.ago, closed_at: Time.current)
      ticket2 = create(:ticket, status: :resolved, created_at: 3.hours.ago, closed_at: Time.current)

      avg = Ticket.average_resolution_time
      expect(avg).to be_within(0.5).of(4.0) # average of 5 and 3 hours
    end

    it 'ignores open tickets' do
      create(:ticket, status: :open)
      ticket = create(:ticket, status: :resolved, created_at: 2.hours.ago, closed_at: Time.current)

      avg = Ticket.average_resolution_time
      expect(avg).to be_within(0.5).of(2.0)
    end

    it 'returns 0 when no resolved tickets exist' do
      create(:ticket, status: :open)

      avg = Ticket.average_resolution_time
      expect(avg).to eq(0)
    end
  end
end
