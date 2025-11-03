require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:user) { nil }
  let(:record) { Object.new }

  describe "default permissions" do
    it { expect(policy.index?).to be false }
    it { expect(policy.show?).to be false }
    it { expect(policy.create?).to be false }
    it { expect(policy.new?).to be false } # delegates to create?
    it { expect(policy.update?).to be false }
    it { expect(policy.edit?).to be false } # delegates to update?
    it { expect(policy.destroy?).to be false }

    it "delegates permit? to the action predicate" do
      expect(policy.permit?(:show)).to be false
    end
  end

  describe ApplicationPolicy::Scope do
    it "requires subclasses to implement resolve" do
      scope = ApplicationPolicy::Scope.new(user, double(:scope))
      expect { scope.resolve }.to raise_error(NoMethodError, /You must define #resolve/)
    end
  end
end
