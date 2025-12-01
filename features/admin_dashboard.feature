Feature: System Performance Dashboard
  As a System Admin
  I want to view a global dashboard showing the total tickets opened vs. closed per category
  So that I can identify which departments are overwhelmed

  Scenario: Admin can access the performance dashboard
    Given I am logged in as an admin
    When I visit the admin dashboard page
    Then I should see the page title "System Performance Dashboard"
    And I should see "Total Tickets" metric card
    And I should see "Open Tickets" metric card
    And I should see "Resolved Tickets" metric card
    And I should see "Avg Resolution Time" metric card

  Scenario: Dashboard displays average resolution time metric
    Given I am logged in as an admin
    And there are resolved tickets with varying resolution times
    When I visit the admin dashboard page
    Then I should see the "Average Resolution Time" metric
    And the metric should show a value in hours

  Scenario: Status summary table displays all status counts
    Given I am logged in as an admin
    And there are 5 "open" tickets
    And there are 3 "in_progress" tickets
    And there are 2 "on_hold" tickets
    And there is 1 "resolved" ticket
    When I visit the admin dashboard page
    Then I should see a status summary table
    And the table should show "Open" with count 5
    And the table should show "In Progress" with count 3
    And the table should show "On Hold" with count 2
    And the table should show "Resolved" with count 1

  Scenario: Non-admin user cannot access the performance dashboard
    Given I am logged in as a user
    When I try to visit the admin dashboard page
    Then I should be denied access
