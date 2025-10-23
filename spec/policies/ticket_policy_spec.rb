require 'rails_helper'

RSpec.describe TicketPolicy do
  let(:requester) { FactoryBot.create(:user, role: :user) }
  let(:agent) { FactoryBot.create(:user, role: :staff) }
  let(:admin) { FactoryBot.create(:user, role: :sysadmin) }
  let(:ticket) { FactoryBot.create(:ticket, requester: requester) }

  subject { described_class.new(user, ticket) }

  context 'when user is requester' do
    let(:user) { requester }

    it { expect(subject.permit?(:index)).to be true }
    it { expect(subject.permit?(:show)).to be true }
    it { expect(subject.permit?(:create)).to be true }
    it { expect(subject.permit?(:new)).to be true }
    it { expect(subject.permit?(:update)).to be true }
    it { expect(subject.permit?(:edit)).to be true }
    it { expect(subject.permit?(:destroy)).to be true }
    it { expect(subject.permit?(:close)).to be true }
    it { expect(subject.permit?(:assign)).to be false }

    context 'when ticket is closed' do
      before { ticket.update(status: :closed) }
      it { expect(subject.permit?(:update)).to be false }
      it { expect(subject.permit?(:edit)).to be false }
      it { expect(subject.permit?(:destroy)).to be false }
      it { expect(subject.permit?(:close)).to be false }
    end
  end

  context 'when user is agent' do
    let(:user) { agent }

    it { expect(subject.permit?(:index)).to be true }
    it { expect(subject.permit?(:show)).to be true }
    it { expect(subject.permit?(:create)).to be true }
    it { expect(subject.permit?(:new)).to be true }
    it { expect(subject.permit?(:update)).to be true }
    it { expect(subject.permit?(:edit)).to be true }
    it { expect(subject.permit?(:assign)).to be true }
    it { expect(subject.permit?(:destroy)).to be false }
    it { expect(subject.permit?(:close)).to be false }
  end

  context 'when user is admin' do
    let(:user) { admin }

    it { expect(subject.permit?(:index)).to be true }
    it { expect(subject.permit?(:show)).to be true }
    it { expect(subject.permit?(:create)).to be true }
    it { expect(subject.permit?(:new)).to be true }
    it { expect(subject.permit?(:update)).to be true }
    it { expect(subject.permit?(:edit)).to be true }
    it { expect(subject.permit?(:assign)).to be true }
    it { expect(subject.permit?(:destroy)).to be false }
    it { expect(subject.permit?(:close)).to be false }
  end
end
