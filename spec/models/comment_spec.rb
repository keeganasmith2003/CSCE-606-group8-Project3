require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { should belong_to(:ticket) }
    it { should belong_to(:author).class_name('User') }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'enums' do
    it 'defines visibility enum with prefixed helpers' do
      expect(Comment.visibilities.symbolize_keys).to eq({ public: 0, internal: 1 })
      expect(build(:comment)).to respond_to(:visibility_public?)
      expect(build(:comment)).to respond_to(:visibility_internal!)
    end
  end

  describe 'scopes' do
    it 'orders chronologically' do
      ticket = create(:ticket)
      older = create(:comment, ticket: ticket, created_at: 2.days.ago)
      newer = create(:comment, ticket: ticket, created_at: 1.day.ago)

      expect(ticket.comments.chronological).to eq([ older, newer ])
    end
  end
end
