# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
user = User.find_or_initialize_by(
  provider: "google_oauth2",
  uid:      "keeganasmith2003" # keep stable so it's idempotent
)

user.assign_attributes(
  email:    "keeganasmith2003@tamu.edu",
  name:     "Keegana Smith",
  image_url: "https://example.com/keegana.png",
  role:     :sysadmin
)

# (Optional) if you want seed tokens for local testing:
# user.access_token  = "seed-access-token"
# user.refresh_token = "seed-refresh-token"
# user.access_token_expires_at = 2.hours.from_now

user.save!
puts "Seeded user: #{user.email} (role: #{user.role})"
