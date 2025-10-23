class CommentPolicy < ApplicationPolicy
  def create?
    return false unless record.ticket.open?

    if user.requester?
      record.ticket.requester == user && record.visibility_public?
    elsif user.agent? || user.admin?
      true
    else
      false
    end
  end
end
