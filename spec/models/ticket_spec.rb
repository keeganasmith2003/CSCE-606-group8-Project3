require 'rails_helper'

RSpec.describe Ticket, type: :model do
  let(:requester) { FactoryBot.create(:user, role: :user) }
  let(:agent) { FactoryBot.create(:user, role: :staff) }
  let(:ticket) { FactoryBot.create(:ticket, requester: requester, assignee: agent) }

  describe 'associations' do
    it { should belong_to(:requester).class_name('User') }
    it { should belong_to(:assignee).class_name('User').optional }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(open: 0, pending: 1, resolved: 2, closed: 3) }
    it { should define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2) }
  end

  describe 'validations' do
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:priority) }
    it { should validate_presence_of(:category) }
    it { should validate_inclusion_of(:category).in_array(Ticket::CATEGORY_OPTIONS) }
    it { should validate_presence_of(:requester) }
  end

  describe 'defaults' do
    it 'defaults priority to medium' do
      expect(Ticket.new.priority).to eq("medium")
    end
  end

  describe '#set_closed_at' do
    context 'when status changes to closed' do
      it 'sets closed_at timestamp' do
        ticket.update(status: :closed)
        expect(ticket.closed_at).to be_present
      end
    end

    context 'when status changes from closed to another' do
      it 'clears closed_at timestamp' do
        ticket.update(status: :closed)
        ticket.update(status: :open)
        ticket.reload
        expect(ticket.closed_at).to be_nil
      end
    end
  end
end
