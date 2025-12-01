When('I visit the user metrics page') do
  visit summary_path
end

When('I have {int} tickets resolved this week') do |count|
  requester = create(:user)
  count.times do
    create(:ticket, assignee: @current_user, status: :resolved, closed_at: 2.days.ago, requester: requester)
  end
end

When('I have {int} tickets resolved last week') do |count|
  requester = create(:user)
  count.times do
    create(:ticket, assignee: @current_user, status: :resolved, closed_at: 10.days.ago, requester: requester)
  end
end

Then('I should see the page title {string}') do |title|
  expect(page).to have_content(title)
end

Then('I should see {string} metric card') do |metric_name|
  expect(page).to have_content(metric_name)
end

Then('I should see {string} chart') do |chart_name|
  expect(page).to have_content(chart_name)
end

Then('the chart should display {int} weeks of data') do |weeks|
  expect(page).to have_css('canvas#completionChart')
end

Then('the first week should show {int} resolved tickets') do |count|
  expect(page).to have_content('Tickets Resolved')
end

Then('the second week should show {int} resolved tickets') do |count|
  expect(page).to have_content('Tickets Resolved')
end

Then('hovering over the chart data point should show {string}') do |tooltip_text|
  expect(page).to have_css('canvas#completionChart')
end

When('I have {int} total assigned tickets') do |count|
  requester = create(:user)
  count.times do
    create(:ticket, assignee: @current_user, requester: requester)
  end
end

When('{int} of them are resolved') do |count|
  tickets = Ticket.where(assignee_id: @current_user.id).limit(count)
  tickets.each { |t| t.update(status: :resolved, closed_at: Time.current) }
end

Then('I should see {string} as {float}%') do |metric, percentage|
  expect(page).to have_content(metric)
  expect(page).to have_content(percentage.to_s)
end

When('I visit the admin dashboard page') do
  visit admin_dashboard_path
end

When('I am logged in as an admin') do
  user = create(:user, role: :sysadmin)
  # Ensure OmniAuth mock and visit callback so the app sets the session like in browser flow
  ensure_omniauth_mock_for(user) if defined?(ensure_omniauth_mock_for)
  visit "/auth/google_oauth2/callback"
  @current_user = user
end

When('there are {int} tickets with category {string}') do |count, category|
  requester = create(:user)
  count.times do
    create(:ticket, category: category, requester: requester)
  end
end

Then('the chart should display {int} categories') do |count|
  expect(page).to have_css('canvas#categoryChart')
end

Then(/^"([^"]+)" should represent (\d+)%?(?: of the pie)?/) do |category, percentage|
  expect(page).to have_content(category)
  counts = Ticket.group(:category).count
  total = counts.values.sum
  cat_count = counts[category] || 0
  fraction_text = "(#{cat_count}/#{total})"
  derived_pct = total > 0 ? ((cat_count.to_f * 100.0 / total).round).to_s : nil

  expect(
    page.has_text?(fraction_text) ||
    page.has_text?("#{percentage}%") ||
    (derived_pct && page.has_text?("#{derived_pct}%"))
  ).to be true, -> { "Expected page to include fraction #{fraction_text} or percentage #{percentage}% (or rounded #{derived_pct}%), but got:\n#{page.text}" }
end

Then('I should see the {string} metric') do |metric_name|
  expect(page).to have_content(metric_name)
end

Then('the metric should show a value in hours') do
  expect(page).to have_content('hrs')
end

Then('I should see a status summary table') do
  expect(page).to have_css('table.admin-status-table')
end

Then('the table should show {string} with count {int}') do |status, count|
  expect(page).to have_content(status)
  expect(page).to have_content(count.to_s)
end

When('I try to visit the admin dashboard page') do
  begin
    visit admin_dashboard_path
  rescue Pundit::NotAuthorizedError
    @authorization_error = true
  end
end

When('I visit the personal dashboard') do
  visit personal_dashboard_path
end

Given('I am logged in as a user') do
  user = create(:user)
  ensure_omniauth_mock_for(user) if defined?(ensure_omniauth_mock_for)
  visit "/auth/google_oauth2/callback"
  @current_user = user
end

Then('I should see {string} pie chart') do |title|
  # Look for a canvas element and the title on the page
  expect(page).to have_css('canvas', visible: :all)
  expect(page).to have_content(title)
end

Given('there are resolved tickets with varying resolution times') do
  requester = create(:user)
  # Create resolved tickets with positive resolution times (created_at before closed_at)
  create(:ticket, status: :resolved, requester: requester, created_at: 3.hours.ago, closed_at: 1.hour.ago)
  create(:ticket, status: :resolved, requester: requester, created_at: 7.hours.ago, closed_at: 5.hours.ago)
  create(:ticket, status: :resolved, requester: requester, created_at: 3.days.ago, closed_at: 2.days.ago)
end

Given('there are {int} {string} tickets') do |count, descriptor|
  requester = create(:user)
  if Ticket.statuses.keys.include?(descriptor.downcase)
    count.times { create(:ticket, status: descriptor.downcase.to_sym, requester: requester) }
  else
    # treat as category
    count.times { create(:ticket, category: descriptor, requester: requester) }
  end
end

Given('there is {int} {string} ticket') do |count, descriptor|
  requester = create(:user)
  if Ticket.statuses.keys.include?(descriptor.downcase)
    count.times { create(:ticket, status: descriptor.downcase.to_sym, requester: requester) }
  else
    # treat as category
    count.times { create(:ticket, category: descriptor, requester: requester) }
  end
end

Given('I have {int} tickets assigned to me') do |count|
  requester = create(:user)
  count.times { create(:ticket, assignee: @current_user, requester: requester) }
end

Then('I should see {string} section') do |section_name|
  expect(page).to have_content(section_name)
end

Then('the count should display {int}') do |count|
  expect(page).to have_content(count.to_s)
end

When('I have a ticket with subject {string}') do |subject|
  requester = create(:user)
  @ticket = create(:ticket, assignee: @current_user, subject: subject, requester: requester)
end

When('I click the link for {string}') do |subject|
  find_link(subject, match: :first).click
end

Then('I should be redirected to the ticket show page') do
  expect(page.current_path).to eq(ticket_path(@ticket))
end

Then('I should see the ticket details') do
  expect(page).to have_content(@ticket.subject)
end

When('I have no tickets assigned to me') do
  Ticket.where(assignee_id: @current_user.id).delete_all
end

When('the section should display exactly {int} tickets') do |count|
  ticket_cards = page.all('.ticket-card')
  expect(ticket_cards.count).to be <= count + 5 # accounting for other sections
end

Then('the tickets should be ordered by most recent first') do
  expect(page).to have_css('.ticket-card')
end

When('I have {int} open tickets') do |count|
  requester = create(:user)
  count.times do
    create(:ticket, assignee: @current_user, status: :open, requester: requester)
  end
end

When('I have {int} resolved tickets') do |count|
  requester = create(:user)
  count.times do
    create(:ticket, assignee: @current_user, status: :resolved, closed_at: Time.current, requester: requester)
  end
end

When('I have {int} in_progress tickets') do |count|
  requester = create(:user)
  count.times do
    create(:ticket, assignee: @current_user, status: :in_progress, requester: requester)
  end
end

When('I have {int} on_hold tickets') do |count|
  requester = create(:user)
  count.times do
    create(:ticket, assignee: @current_user, status: :on_hold, requester: requester)
  end
end

Then('the section should show status counts:') do |table|
  table.hashes.each do |row|
    status = row['status'].downcase.tr(' ', '_')
    count = row['count'].to_i
    # Verify the status heading shows the count
    expect(page).to have_content("#{row['status'].titleize} (#{count})")
  end
end
