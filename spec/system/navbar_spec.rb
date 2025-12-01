require "rails_helper"

RSpec.describe "Navbar links", type: :request do
  def doc
    Nokogiri::HTML(response.body)
  end

  it "sysadmin sees Teams index link" do
    user = User.create!(provider: "google_oauth2", uid: "x1", email: "sys@example.com", role: :sysadmin)
    sign_in(user)
    get dashboard_path       # After sign-in, users go to dashboard

    link = doc.at_css("a.nav-link[href='#{teams_path}']")
    expect(link&.text).to eq("Teams")
  end

  it "staff sees their team link (or Teams if none)" do
    user = User.create!(provider: "google_oauth2", uid: "x2", email: "staff@example.com", role: :staff)
    team = Team.create!(name: "Support")
    TeamMembership.create!(team: team, user: user)

    sign_in(user)
    get dashboard_path       # After sign-in, users go to dashboard

    link = doc.at_css("a.nav-link[href='#{team_path(team)}']")
    expect(link&.text).to eq("Support")
  end

  it "staff without team sees Teams index fallback" do
    user = User.create!(provider: "google_oauth2", uid: "x3", email: "staff2@example.com", role: :staff)
    sign_in(user)
    get dashboard_path       # After sign-in, users go to dashboard

    link = doc.at_css("a.nav-link[href='#{teams_path}']")
    expect(link&.text).to eq("Teams")
  end
end
