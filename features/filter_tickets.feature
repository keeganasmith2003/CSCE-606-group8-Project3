Feature: Filter Tickets
  As a user
  So that I can quickly find the tickets I care about
  I want to filter the tickets list

  Background:
    Given I log in with Google as uid "12345", email "testuser@example.com", name "Test User"
    And the following tickets exist:
      | subject                   | description              | status       | category          | approval_status | assignee_email        |
      | Login Issue               | Cannot access account    | open         | Account Access    | pending         | testuser@example.com  |
      | Bug Report                | App crashes sometimes    | in_progress  | Technical Issue   | approved        | testuser@example.com  |
      | Feature Request: Dark     | Add dark mode            | open         | Feature Request   | pending         | testuser@example.com  |
      | Old Ticket                | Already resolved issue   | resolved     | Technical Issue   | rejected        | other@example.com     |

  Scenario: Viewing all submitted tickets
    When I go to the tickets list page
    Then I should see "Login Issue"
    And I should see "Bug Report"
    And I should see "Feature Request: Dark"
    And I should see "Old Ticket"

  Scenario: Filtering tickets by status
    When I go to the tickets list page
    And I select "Open" from "Status"
    And I press "Filter"
    Then I should see "Login Issue"
    And I should see "Feature Request: Dark"
    And I should not see "Bug Report"
    And I should not see "Old Ticket"

  Scenario: Filtering tickets by category
    When I go to the tickets list page
    And I select "Technical Issue" from "Category"
    And I press "Filter"
    Then I should see "Bug Report"
    And I should see "Old Ticket"
    And I should not see "Login Issue"
    And I should not see "Feature Request: Dark"

  Scenario: Filtering tickets by approval status
    When I go to the tickets list page
    And I select "Approved" from "Approval" 
    And I press "Filter"
    Then I should see "Bug Report"
    And I should not see "Login Issue"
    And I should not see "Feature Request: Dark"
    And I should not see "Old Ticket"

  Scenario: Filtering tickets by assignee
    When I go to the tickets list page
    And I select "Test User" from "Assignee"
    And I press "Filter"
    Then I should see "Login Issue"
    And I should see "Bug Report"
    And I should see "Feature Request: Dark"
    And I should not see "Old Ticket"

  Scenario: Searching tickets by keyword
    When I go to the tickets list page
    And I fill in "Search" with "crash"
    And I press "Filter"
    Then I should see "Bug Report"
    And I should not see "Login Issue"
    And I should not see "Feature Request: Dark"
    And I should not see "Old Ticket"
