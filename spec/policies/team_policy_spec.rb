# spec/policies/team_policy_spec.rb
require "rails_helper"

RSpec.describe TeamPolicy do
  let(:team_record) { Team.new(name: "Support") }

  describe "as sysadmin" do
    let(:user) { User.new(provider: "google_oauth2", uid: "sa", email: "sys@example.com", role: :sysadmin) }

    it "allows full access" do
      policy = described_class.new(user, team_record)
      expect(policy.index?).to   be true
      expect(policy.show?).to    be true
      expect(policy.create?).to  be true
      expect(policy.update?).to  be true
      expect(policy.destroy?).to be true
    end

    it "scope returns all teams" do
      a = Team.create!(name: "A")
      b = Team.create!(name: "B")
      scope = Pundit.policy_scope!(user, Team)
      expect(scope).to include(a, b)
    end
  end

  describe "as staff" do
    let(:user) { User.create!(provider: "google_oauth2", uid: "st", email: "staff@example.com", role: :staff) }

    it "allows read but denies write" do
      policy = described_class.new(user, team_record)
      expect(policy.index?).to   be true
      expect(policy.show?).to    be true
      expect(policy.create?).to  be false
      expect(policy.update?).to  be false
      expect(policy.destroy?).to be false
    end

    it "scope returns only teams the user belongs to" do
      mine  = Team.create!(name: "Mine")
      other = Team.create!(name: "Other")
      TeamMembership.create!(team: mine, user: user)

      scope = Pundit.policy_scope!(user, Team)
      expect(scope).to include(mine)
      expect(scope).not_to include(other)
    end
  end
end
