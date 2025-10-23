class TicketPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.requester? || user.agent? || user.admin?
  end

  def new?
    create?
  end

  def update?
    return false if record.closed?
    return true if user.admin?
    return true if user.agent?
    return true if user.requester? && record.requester == user
    false
  end

  def edit?
    update?
  end

  def destroy?
    return false unless record.open?
    user.requester? && record.requester == user
  end

  def close?
    record.open? && record.requester == user
  end

  def assign?
    user.agent? || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.agent?
        scope.all
      else
        scope.where(requester: user)
      end
    end
  end
end
