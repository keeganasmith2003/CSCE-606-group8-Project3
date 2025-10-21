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

  # Create or update from OmniAuth auth hash (e.g., for "google_oauth2")
  def self.from_omniauth(auth)
    raise ArgumentError, "auth must include provider and uid" unless auth && auth["provider"] && auth["uid"]

    user  = find_or_initialize_by(provider: auth["provider"], uid: auth["uid"])
    info  = auth["info"] || {}
    creds = auth["credentials"] || {}

    user.email     = info["email"] if info["email"].present?
    user.name      = info["name"]  if info["name"].present?
    user.image_url = info["image"] if info["image"].present?

    user.access_token  = creds["token"]         if creds["token"].present?
    user.refresh_token = creds["refresh_token"] if creds["refresh_token"].present?

    if creds["expires_at"].present?
      user.access_token_expires_at = case expires_at = creds["expires_at"]
      when Numeric then Time.at(expires_at)
      when String  then Time.parse(expires_at)
      when Time    then expires_at
      else
                                       expires_at # let AR try to cast
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
