Feature: My Tickets Dashboard
  As a user I want a dashboard summarizing tickets assigned to me grouped by status

  Background:
    Given there is an agent named "Agent Alice"

  Scenario: Viewing my personal dashboard
    Given the following tickets exist:
      | subject        | description    | status   | priority | category         | requester_email     | assignee_email           |
      | Fix CSS bug    | styling issue  | open     | low      | Feature Request  | alice@example.com   | agent.alice@example.com  |
      | Close incident | rollback deploy| resolved | high     | Technical Issue  | bob@example.com     | agent.alice@example.com  |
    When I am logged in as agent "Agent Alice"
    And I go to the dashboard page
    Then I should see "My Tickets Dashboard"
    And I should see "Open"
    And I should see "Resolved"
    And I should see "Fix CSS bug"
    And I should see "Close incident"
