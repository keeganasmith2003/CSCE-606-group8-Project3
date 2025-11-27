Feature: Delete Ticket
  As a user
  So that I can remove requests that are no longer needed
  I want to delete a ticket I created

  Background:
    Given the following tickets exist:
      | subject        | description        | requester_email       |
      | Test Ticket  | Delete this later  | testuser@example.com |
    And I log in with Google as uid "12345", email "testuser@example.com", name "Test Requester"

    Scenario: Successfully deleting a ticket
        Given I am on the ticket page for "Test Ticket"
        When I press "Delete Ticket"
        Then I should see "Ticket deleted successfully."
        And I should not see "Test Ticket" in the ticket list

