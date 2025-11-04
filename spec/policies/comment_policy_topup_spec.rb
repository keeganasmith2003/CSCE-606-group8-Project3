require 'rails_helper'

RSpec.describe CommentPolicy, 'additional cases' do
  let(:requester) { create(:user, :requester) }
  let(:other_user) { create(:user, :requester) }
  let(:agent) { create(:user, :agent) }
  let(:ticket) { create(:ticket, requester: requester) }

  it 'denies when user is neither requester nor staff/admin' do
    comment = build(:comment, ticket: ticket, author: other_user, visibility: :public)
    policy = described_class.new(other_user, comment)
    expect(policy.create?).to be false
  end

  it 'denies requester if commenting on someone else\'s ticket even if public' do
    other_ticket = create(:ticket, requester: other_user)
    comment = build(:comment, ticket: other_ticket, author: requester, visibility: :public)
    policy = described_class.new(requester, comment)
    expect(policy.create?).to be false
  end

  it 'allows agent regardless of visibility' do
    [ :public, :internal ].each do |vis|
      comment = build(:comment, ticket: ticket, author: agent, visibility: vis)
      policy = described_class.new(agent, comment)
      expect(policy.create?).to be true
    end
  end
end
