class Team < ApplicationRecord
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships, source: :user
  has_many :tickets, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
