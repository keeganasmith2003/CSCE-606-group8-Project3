class Ticket < ApplicationRecord
  CATEGORY_OPTIONS = [
    "Technical Issue",
    "Account Access",
    "Feature Request"
  ].freeze

  belongs_to :requester, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :comments, dependent: :destroy

  enum :status, { open: 0, pending: 1, resolved: 2, closed: 3 }, validate: true
  enum :priority, { low: 0, medium: 1, high: 2 }, validate: true

  attribute :priority, :integer, default: -> { Ticket.priorities[:medium] }

  validates :subject, presence: true
  validates :description, presence: true
  validates :status, presence: true
  validates :priority, inclusion: { in: priorities.keys }
  validates :category, presence: true, inclusion: { in: CATEGORY_OPTIONS }
  validates :requester, presence: true

  before_save :set_closed_at

  private

  def set_closed_at
    if closed?
      self.closed_at = Time.current unless closed_at.present?
    else
      self.closed_at = nil
    end
  end
end
