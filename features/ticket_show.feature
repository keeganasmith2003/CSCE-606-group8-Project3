Feature: View ticket details
  As a user
  I can open a ticket to see its details (status, assignee, comments, history)

  Background:
    Given OmniAuth is in test mode
    And I am on the home page
    And the Google mock returns uid "viewer-1", email "viewer@example.com", name "Viewer Name"
    When I click "Login with Google"

  Scenario: View an open ticket with no assignee and no comments
    Given the following tickets exist:
      | subject                           | description                          | status | priority | category         | requester_email     |
      | App crash on ticket submission    | 500 error when submitting the form   | open   | high     | Technical Issue  | viewer@example.com  |
    And I am on the ticket page for "App crash on ticket submission"
    Then I should see "App crash on ticket submission"
    And I should see "Open"
    And I should see "Priority"
    And I should see "High"
    And I should see "Technical Issue"
    And I should see "Submitter"
    And I should see "Viewer Name"
    And I should see "Unassigned"
    And I should see "Discussion"
    And I should see "No comments yet."

  Scenario: View a resolved ticket shows resolved timestamp (history)
    Given the following tickets exist:
      | subject                        | description                | status   | priority | category         | requester_email     |
      | Billing discrepancy           | Charged twice last month   | resolved | high     | Technical Issue  | viewer@example.com  |
    And I am on the ticket page for "Billing discrepancy"
    Then I should see "Billing discrepancy"
    And I should see "Resolved"
    And I should see "Priority"
    And I should see "High"
