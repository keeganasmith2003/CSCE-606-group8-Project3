class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :author, class_name: "User"

  enum :visibility, { public: 0, internal: 1 }, validate: true

  validates :body, presence: true
  validates :visibility, presence: true

  scope :chronological, -> { order(created_at: :asc) }
end
