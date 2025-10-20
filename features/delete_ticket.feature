Feature: Delete Ticket
  As a user
  So that I can remove requests that are no longer needed
  I want to delete a ticket I created

  Background:
    Given the following tickets exist:
      | title        | description        |
      | Test Ticket  | Delete this later  |

    Scenario: Successfully deleting a ticket
        Given I am on the ticket page for "Test Ticket"
        When I press "Destroy"
        Then I should see "Ticket was successfully destroyed"
        And I should not see "Test Ticket"

