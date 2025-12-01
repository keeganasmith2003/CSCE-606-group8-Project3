Feature: Personal Dashboard
  As a Standard User
  I want to view a dashboard summarizing tickets assigned to me
  So that I can quickly identify my immediate workload

  Scenario: Dashboard displays my open ticket count
    Given I am logged in as a user
    And I have 3 open tickets
    And I have 2 resolved tickets
    When I visit the personal dashboard
    Then I should see "My Open Tickets" section
    And the count should display 3

  Scenario: Dashboard lists 5 most recently updated tickets
    Given I am logged in as a user
    And I have 10 tickets assigned to me
    When I visit the personal dashboard
    Then I should see "5 Most Recently Updated Tickets" section
    And the section should display exactly 5 tickets
    And the tickets should be ordered by most recent first

  Scenario: Clicking a ticket link redirects to ticket show page
    Given I am logged in as a user
    And I have a ticket with subject "Fix login bug"
    When I visit the personal dashboard
    And I click the link for "Fix login bug"
    Then I should be redirected to the ticket show page
    And I should see the ticket details

  Scenario: Dashboard shows no tickets message when none are assigned
    Given I am logged in as a user
    And I have no tickets assigned to me
    When I visit the personal dashboard
    Then I should see "No tickets assigned to you yet."

  Scenario: Dashboard groups remaining tickets by status
    Given I am logged in as a user
    And I have 7 open tickets
    And I have 3 in_progress tickets
    And I have 2 on_hold tickets
    And I have 5 resolved tickets
    When I visit the personal dashboard
    Then I should see "Tickets by Status" section
    And the section should show status counts:
      | status | count |
      | Open | 7 |
      | In Progress | 3 |
      | On Hold | 2 |
      | Resolved | 5 |
