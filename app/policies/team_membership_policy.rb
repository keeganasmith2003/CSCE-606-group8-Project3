# app/policies/team_membership_policy.rb
class TeamMembershipPolicy < ApplicationPolicy
  def create?
    user.sysadmin?
  end

  def update?
    user.sysadmin?
  end

  def destroy?
    user.sysadmin?
  end

  # Only sysadmins can set user_id and role via params
  def permitted_attributes
    if user.sysadmin?
      [ :user_id, :role ]
    else
      [] # or [:user_id] if you allow self-join; never :role here
    end
  end
end
