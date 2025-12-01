class MetricsController < ApplicationController
  before_action :authenticate_user!

  # Personal metrics dashboard for the current user
  def user_metrics
    authorize :metric, :user_metrics?

    @completion_data = Ticket.completion_rate_by_week(current_user, 30)
    @open_tickets_count = Ticket.where(assignee_id: current_user.id, status: :open).count
    @resolved_tickets_count = Ticket.where(assignee_id: current_user.id, status: :resolved).count
    @total_assigned = @open_tickets_count + @resolved_tickets_count
  end

  # Admin system performance dashboard
  def admin_dashboard
    authorize :metric, :admin_dashboard?

    @tickets_by_category = Ticket.tickets_by_category
    @average_resolution_time = Ticket.average_resolution_time
    @total_tickets = Ticket.count
    @resolved_count = Ticket.where(status: :resolved).count
    @open_count = Ticket.where(status: :open).count
  end
end
