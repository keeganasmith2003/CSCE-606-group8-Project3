class TicketPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if user.admin? || user.agent?
    # Allow requesters to view their own tickets and assignees to view tickets assigned to them
    return true if user.requester? && record.requester == user
    return true if record.assignee == user
    false
  end

  def create?
    user.requester? || user.agent? || user.admin?
  end

  def new?
    create?
  end

  def permitted_attributes
    attrs = %i[subject description priority category]
    attrs << :status if change_status?
    attrs << :assignee_id if user.admin? || user.agent?
    attrs << :team_id     if user.admin? || user.agent?
    if user.admin? || user.agent?
      attrs << :approval_status
      attrs << :approval_reason
      attrs << { attachments: [] }
    end
    attrs
  end

  def update?
    return false if record.resolved?
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
    !record.resolved? && record.requester == user
  end

  def assign?
    user.agent? || user.admin?
  end

  def approve?
    user.agent? || user.admin?
  end

  def reject?
    user.agent? || user.admin?
  end

  def change_status?
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
