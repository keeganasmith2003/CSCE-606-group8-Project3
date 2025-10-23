Feature: Edit Ticket
  As a user
  So that I can clarify or update my issue details
  I want to edit my ticket before staff picks it up

  Background:
    Given the following tickets exist:
      | subject       | description           | status | priority | category | requester_email       |
  | Password Bug  | Old description text  | open   | low      | General  | testuser@example.com |
  And I log in with Google as uid "12345", email "requester@example.com", name "Test Requester"

  # --- Core scenario: editing description ---
  Scenario: Successfully editing the ticket description
    Given I am on the edit page for "Password Bug"
    When I fill in "Description" with "Updated description text"
    And I press "Update Ticket"
    Then I should see "Ticket was successfully updated"
    And I should see "Updated description text"

  # --- Additional scenario: editing status ---
  Scenario: Successfully changing the ticket status
    Given I am on the edit page for "Password Bug"
    When I select "Closed" from "Status"
    And I press "Update Ticket"
    Then I should see "Ticket was successfully updated"
    And I should see "Closed"

  # --- Additional scenario: editing priority ---
  Scenario: Successfully changing the ticket priority
    Given I am on the edit page for "Password Bug"
    When I select "high" from "Priority"
    And I press "Update Ticket"
    Then I should see "Ticket was successfully updated"
    And I should see "high"

  # --- Additional scenario: editing category ---
  Scenario: Successfully editing the ticket category
    Given I am on the edit page for "Password Bug"
    When I fill in "Category" with "Account"
    And I press "Update Ticket"
    Then I should see "Ticket was successfully updated"
    And I should see "Account"
