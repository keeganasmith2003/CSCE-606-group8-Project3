# db/seeds.rb

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Flush existing data to ensure a clean reseed (respect FK constraints)
puts "Flushing existing data..."
Comment.delete_all
Ticket.delete_all
TeamMembership.delete_all
Setting.delete_all
User.delete_all

user = User.find_or_initialize_by(
  provider: "google_oauth2",
  uid:      "keeganasmith2003"
)

user.assign_attributes(
  email:    "keeganasmith2003@tamu.edu",
  name:     "Keegan Smith",
  image_url: "https://example.com/keegana.png",
  role:     :sysadmin
)

user.save!
puts "Seeded user: #{user.email} (role: #{user.role})"

# === Settings ===
# Enable round-robin by default for dev/demo; your app checks Setting.auto_round_robin?
Setting.set("assignment_strategy", "round_robin")

# === Users ===
# Your User enum is: enum :role, { user: 0, sysadmin: 1, staff: 2 }
def seed_user!(provider:, uid:, email:, name:, image_url:, role:)
  u = User.find_or_initialize_by(provider: provider, uid: uid)
  u.assign_attributes(email: email, name: name, image_url: image_url, role: role)
  u.save!
  u
end

requester  = seed_user!(
  provider:  "google_oauth2",
  uid:       "user1",
  email:     "dummy.requester@example.com",
  name:      "Dummy Requester 1",
  image_url: "https://example.com/requester.png",
  role:      :user
)

requester2 = seed_user!(
  provider:  "google_oauth2",
  uid:       "user2",
  email:     "dummy.requester2@example.com",
  name:      "Dummy Requester 2",
  image_url: "https://example.com/requester2.png",
  role:      :user
)

agent1 = seed_user!(
  provider:  "google_oauth2",
  uid:       "agent1",
  email:     "support.agent@example.com",
  name:      "Support Agent 1",
  image_url: "https://example.com/support_agent.png",
  role:      :staff
)

agent2 = seed_user!(
  provider:  "google_oauth2",
  uid:       "agent2",
  email:     "support.agent2@example.com",
  name:      "Support Agent 2",
  image_url: "https://example.com/support_agent2.png",
  role:      :staff
)

# Additional sample users
requester3 = seed_user!(
  provider:  "google_oauth2",
  uid:       "user3",
  email:     "dummy.requester3@example.com",
  name:      "Dummy Requester 3",
  image_url: "https://example.com/requester3.png",
  role:      :user
)

agent3 = seed_user!(
  provider:  "google_oauth2",
  uid:       "agent3",
  email:     "support.agent3@example.com",
  name:      "Support Agent 3",
  image_url: "https://example.com/support_agent3.png",
  role:      :staff
)

admin2 = seed_user!(
  provider:  "google_oauth2",
  uid:       "admin2",
  email:     "admin2@example.com",
  name:      "Admin User 2",
  image_url: "https://example.com/admin2.png",
  role:      :sysadmin
)

puts "Users seeded: #{User.count}"

# === Teams & Memberships ===
support = Team.find_or_create_by!(name: "Support") do |t|
  t.description = "Tier 1 helpdesk"
end
ops = Team.find_or_create_by!(name: "Ops") do |t|
  t.description = "Operations & SRE"
end

# Ensure memberships so Ticket validation passes (assignee must belong to team)
TeamMembership.find_or_create_by!(team: support, user: agent1)
TeamMembership.find_or_create_by!(team: ops,     user: agent2)

# Optional: cross-staff membership if you want them on both teams
# TeamMembership.find_or_create_by!(team: support, user: agent2)
# TeamMembership.find_or_create_by!(team: ops,     user: agent1)

puts "Teams seeded: #{Team.count} | Memberships: #{TeamMembership.count}"

# === Tickets ===
# Valid enums per model:
# status:   { open: 0, in_progress: 1, on_hold: 2, resolved: 3 }
# priority: { low: 0, medium: 1, high: 2 }
# category: must be in Ticket::CATEGORY_OPTIONS

tickets_attrs = [
  {
    subject:      "App crash on ticket submission",
    description:  "Every time I try to submit a ticket, the app crashes with a 500 error.",
    status:       :on_hold,
    priority:     :high,
    requester:    requester,
    assignee:     agent1,                  # belongs to Support
    team:         support,                 # assign to Support team
    category:     "Technical Issue"
  },
  {
    subject:      "Cannot change account password",
    description:  "The password reset link redirects to an expired page.",
    status:       :in_progress,
    priority:     :medium,
    requester:    requester,
    assignee:     agent1,                  # belongs to Support
    team:         support,                 # assign to Support team
    category:     "Account Access"
  },
  {
    subject:      "Feature request: Email notifications for updates",
    description:  "Would be great if I could receive an email when the ticket status changes.",
    status:       :open,
    priority:     :low,
    requester:    requester,
    assignee:     nil,                     # unassigned agent
    team:         support,                 # routed to Support but not yet picked up
    category:     "Feature Request"
  },
  {
    subject:      "Billing discrepancy for premium plan",
    description:  "Charged twice for the same month on my credit card statement.",
    status:       :resolved,
    priority:     :high,
    requester:    requester2,
    assignee:     agent2,                  # belongs to Ops
    team:         ops,                     # assign to Ops team
    category:     "Technical Issue"
    # closed_at will auto-set due to before_save when resolved?
  },
  {
    subject:      "Resolved: UI glitch on dashboard",
    description:  "Dashboard charts overlapped on Safari; fix deployed.",
    status:       :resolved,
    priority:     :medium,
    requester:    requester2,
    assignee:     agent2,                  # belongs to Ops
    team:         ops,                     # assign to Ops team
    category:     "Technical Issue"
  },
  {
    subject:      "Login page loads slowly",
    description:  "Initial load of the login page takes ~8 seconds intermittently.",
    status:       :open,
    priority:     :medium,
    requester:    requester3,
    assignee:     agent3,
    category:     "Technical Issue"
  },
  {
    subject:      "Feature request: Dark mode for dashboard",
    description:  "Please add a dark theme option for night-time use.",
    status:       :in_progress,
    priority:     :low,
    requester:    requester3,
    assignee:     nil,
    category:     "Feature Request"
  },
  {
    subject:      "Account locked after password attempts",
    description:  "Got locked after two attempts, not five as expected.",
    status:       :open,
    priority:     :high,
    requester:    requester2,
    assignee:     agent3,
    category:     "Account Access"
  }
]

tickets = tickets_attrs.map do |attrs|
  t = Ticket.find_or_initialize_by(subject: attrs[:subject])
  t.assign_attributes(attrs)
  t.save!
  t
end

puts "Tickets seeded/updated: #{tickets.size} (Total in DB: #{Ticket.count})"

# === Comments ===
def seed_comment!(ticket:, author:, body:, visibility:)
  Comment.find_or_create_by!(
    ticket: ticket,
    author: author,
    body:   body,
    visibility: visibility
  )
end

if tickets.any?
  t1 = tickets.find { |t| t.subject == "App crash on ticket submission" }
  t2 = tickets.find { |t| t.subject == "Cannot change account password" }

  if t1
    seed_comment!(
      ticket: t1,
      author: requester,
      body:   "Happens after I attach a screenshot. Without attachment it sometimes works.",
      visibility: :public
    )
    seed_comment!(
      ticket: t1,
      author: agent1,
      body:   "Replicated with attachments > 5MB. Investigating logs.",
      visibility: :internal
    )
  end

  if t2
    seed_comment!(
      ticket: t2,
      author: requester,
      body:   "Tried multiple browsers. Same result.",
      visibility: :public
    )
    seed_comment!(
      ticket: t2,
      author: agent1,
      body:   "Reset token generator rotated; patch queued for deploy.",
      visibility: :internal
    )
    seed_comment!(
      ticket: t2,
      author: agent1,
      body:   "Deployed fix. Please retry the reset link.",
      visibility: :public
    )
  end

  # Additional comments for other sample tickets
  t3 = tickets.find { |t| t.subject == "Login page loads slowly" }
  if t3
    seed_comment!(
      ticket: t3,
      author: requester3,
      body:   "Happens more on mobile network than Wi‑Fi.",
      visibility: :public
    )
    seed_comment!(
      ticket: t3,
      author: agent3,
      body:   "Checking CDN edge logs for high TTFB spikes.",
      visibility: :internal
    )
  end

  t4 = tickets.find { |t| t.subject == "Feature request: Dark mode for dashboard" }
  if t4
    seed_comment!(
      ticket: t4,
      author: requester3,
      body:   "A schedule to switch based on system theme would be great.",
      visibility: :public
    )
  end

  t5 = tickets.find { |t| t.subject == "Account locked after password attempts" }
  if t5
    seed_comment!(
      ticket: t5,
      author: requester2,
      body:   "I can’t log back in even after 30 minutes.",
      visibility: :public
    )
    seed_comment!(
      ticket: t5,
      author: agent3,
      body:   "Lockout threshold misconfigured; preparing hotfix.",
      visibility: :internal
    )
  end
end

puts "Comments seeded (Total in DB: #{Comment.count})"
puts "=============== Seeding complete ==========================="
