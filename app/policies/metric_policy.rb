class MetricPolicy < ApplicationPolicy
  def user_metrics?
    user.present?
  end

  def admin_dashboard?
    user.present? && user.admin?
  end
end
