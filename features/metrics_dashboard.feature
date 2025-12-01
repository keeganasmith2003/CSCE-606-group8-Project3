Feature: Ticket Metrics Dashboard
  As a User
  I want to view a graph of my ticket completion rate over the last 30 days
  So that I can track my personal productivity

  Scenario: View personal metrics dashboard
    Given I am logged in as a user
  When I visit the user metrics page
    Then I should see the page title "My Ticket Metrics"
    And I should see "Total Assigned" metric card
    And I should see "Open" metric card
    And I should see "Resolved" metric card
    And I should see "Tickets Resolved Per Week" chart

  Scenario: Chart shows resolved tickets per week
    Given I am logged in as a user
    And I have 3 tickets resolved this week
    And I have 2 tickets resolved last week
    When I visit the user metrics page
    Then the chart should display 2 weeks of data
    And the first week should show 3 resolved tickets
    And the second week should show 2 resolved tickets

  Scenario: Hovering over data point shows exact count
    Given I am logged in as a user
    And I have 5 tickets resolved this week
    When I visit the user metrics page
    Then hovering over the chart data point should show "Resolved: 5 ticket(s)"

  Scenario: Metrics card displays resolution rate
    Given I am logged in as a user
    And I have 8 total assigned tickets
    And 4 of them are resolved
    When I visit the user metrics page
    Then I should see "Resolution Rate" as 50.0%
