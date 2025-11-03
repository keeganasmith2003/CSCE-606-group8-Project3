class TeamPolicy < ApplicationPolicy
  def index?  = user.agent? || user.admin?
  def show?   = user.agent? || user.admin?
  def create? = user.admin?
  def update? = user.admin?
  def destroy? = user.admin?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      scope.joins(:team_memberships).where(team_memberships: { user_id: user.id })
    end
  end
end
