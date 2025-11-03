# app/models/user.rb
class User < ApplicationRecord
  # Roles: 0=user, 1=sysadmin, 2=staff
  enum :role, { user: 0, sysadmin: 1, staff: 2 }, validate: true

  # Validations
  validates :provider, presence: true
  validates :uid,      presence: true
  validates :email,    presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { case_sensitive: false }
  validates :role,  presence: true

  before_validation :normalize_email
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  # Create or update from OmniAuth auth hash (e.g., for "google_oauth2")
  def self.from_omniauth(auth)
    raise ArgumentError, "auth must include provider and uid" unless auth && auth["provider"] && auth["uid"]

    info  = auth["info"] || {}
    creds = auth["credentials"] || {}
    email = info["email"].to_s.strip.downcase

    # Prefer existing identity, else fall back to same-email user, else new user
    user = find_by(provider: auth["provider"], uid: auth["uid"]) ||
          (email.present? && find_by(email: email)) ||
          new(role: :user) # ensure role is set if you validate presence

    # If this user didn’t have an identity yet, attach it
    user.provider = auth["provider"]
    user.uid      = auth["uid"]

    user.email     = email if email.present?
    user.name      = info["name"]  if info["name"].present?
    user.image_url = info["image"] if info["image"].present?

    if creds["token"].present?
      user.access_token = creds["token"]
    end
    if creds["refresh_token"].present?
      user.refresh_token = creds["refresh_token"]
    end
    if (ea = creds["expires_at"]).present?
      user.access_token_expires_at =
        case ea
        when Numeric then Time.at(ea)
        when String  then Time.parse(ea)
        when Time    then ea
        else ea
        end
    end

    user.save!
    user
  end

  # Handy display helper
  def display_name
    name.presence || email.to_s.split("@").first
  end

  # Role helpers
  def admin?
    sysadmin?
  end

  def agent?
    staff?
  end

  def requester?
    user?
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
