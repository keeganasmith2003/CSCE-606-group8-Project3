class Ticket < ApplicationRecord
  CATEGORY_OPTIONS = [
    "Technical Issue",
    "Account Access",
    "Feature Request"
  ].freeze

  has_paper_trail only: [ :status, :priority, :assignee_id, :team_id, :approval_status, :closed_at ],
                  on: [ :create, :update ]

  belongs_to :requester, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :approver, class_name: "User", optional: true
  has_many_attached :attachments
  has_many :comments, dependent: :destroy

  enum :status, { open: 0, in_progress: 1, on_hold: 2, resolved: 3 }, validate: true
  enum :priority, { low: 0, medium: 1, high: 2 }, validate: true
  enum :approval_status, { pending: 0, approved: 1, rejected: 2 }, prefix: :approval

  validates :subject, presence: true
  validates :description, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORY_OPTIONS }
  validates :requester, presence: true
  validates :approval_reason, presence: true, if: :approval_rejected?

  before_save :track_resolution_timestamp
  after_initialize :set_default_priority, if: :new_record?
  after_initialize :set_default_status, if: :new_record?

  belongs_to :team, optional: true

  validates :customer_service_rating,
            inclusion: { in: 1..5, message: "must be between 1 and 5" },
            allow_nil: true


  private

  def assignee_is_member_of_team
    return if team.members.exists?(id: assignee_id)
    errors.add(:assignee_id, "must belong to the selected team")
  end

  def set_default_priority
    self.priority ||= :medium
  end

  def set_default_status
    self.status ||= :open
  end

  def track_resolution_timestamp
    if resolved?
      self.closed_at = Time.current unless closed_at.present?
    else
      self.closed_at = nil
    end
  end

  public

  # Can this user rate this ticket right now?
  def ratable_by?(user)
    user.present? &&
      user == requester &&
      resolved? &&
      customer_service_rating.nil?
  end

  def customer_service_rated?
    customer_service_rating.present?
  end

  def approve!(user)
    self.approval_status = :approved
    self.approver = user
    # Clear any previous rejection reason when approving
    self.approval_reason = nil
    self.approved_at = Time.current
    save!
  end

  def reject!(user, reason)
    self.approval_status = :rejected
    self.approver = user
    self.approval_reason = reason
    self.approved_at = Time.current
    save!
  end

  # Class methods for dashboard metrics
  class << self
    # Returns resolved tickets grouped by week for the last 30 days
    # Example: { "Week 1" => 5, "Week 2" => 3, "Week 3" => 2 }
    def completion_rate_by_week(user = nil, days = 30)
      thirty_days_ago = days.days.ago.beginning_of_week
      scope = where(status: :resolved).where("closed_at >= ?", thirty_days_ago)
      scope = scope.where(assignee_id: user.id) if user.present?

      grouped = scope.group_by { |t| t.closed_at.strftime("%Y-W%V") }.sort
      labels = []
      data = []

      if grouped.empty?
        # Return empty weeks for the period
        (0...4).each do |i|
          week_start = (days.days.ago.beginning_of_week + (i * 7.days)).strftime("W%V")
          labels << week_start
          data << 0
        end
      else
        grouped.each do |week, tickets|
          labels << week
          data << tickets.size
        end
      end

      { labels: labels, data: data }
    end

    # Returns tickets grouped by category
    # Example: { "Technical Issue" => 10, "Feature Request" => 5 }
    def tickets_by_category
      group(:category).count
    end

    # Returns average resolution time in hours across all resolved tickets
    def average_resolution_time
      resolved_tickets = where(status: :resolved).where("closed_at IS NOT NULL")
      return 0 if resolved_tickets.empty?

      total_hours = resolved_tickets.sum { |t| ((t.closed_at - t.created_at) / 3600).round(2) }
      (total_hours / resolved_tickets.count).round(2)
    end
  end
end
