require 'rails_helper'

RSpec.describe CommentPolicy do
  let(:ticket) { create(:ticket) }
  let(:requester) { ticket.requester }
  let(:agent) { create(:user, role: :staff) }
  let(:admin) { create(:user, role: :sysadmin) }

  subject(:policy) { described_class.new(user, comment) }

  context 'as requester' do
    let(:user) { requester }

    context 'with public visibility' do
      let(:comment) { build(:comment, ticket: ticket, author: user, visibility: :public) }

      it { expect(policy.create?).to be true }
    end

    context 'with internal visibility' do
      let(:comment) { build(:comment, ticket: ticket, author: user, visibility: :internal) }

      it { expect(policy.create?).to be false }
    end

    context 'when ticket is closed' do
      let(:comment) { build(:comment, ticket: ticket, author: user, visibility: :public) }

      before { ticket.update!(status: :closed) }

      it { expect(policy.create?).to be false }
    end
  end

  context 'as agent' do
    let(:user) { agent }

    context 'with internal visibility' do
      let(:comment) { build(:comment, ticket: ticket, author: user, visibility: :internal) }

      it { expect(policy.create?).to be true }
    end

    context 'when ticket is closed' do
      let(:comment) { build(:comment, ticket: ticket, author: user, visibility: :public) }

      before { ticket.update!(status: :closed) }

      it { expect(policy.create?).to be false }
    end
  end

  context 'as admin' do
    let(:user) { admin }
    let(:comment) { build(:comment, ticket: ticket, author: user, visibility: :internal) }

    it { expect(policy.create?).to be true }
  end
end
