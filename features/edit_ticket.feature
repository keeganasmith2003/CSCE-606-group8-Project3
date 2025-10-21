Feature: Edit Ticket
  As a user
  So that I can clarify my issue
  I want to edit the description of a ticket before staff picks it up

  Background:
    Given the following tickets exist:
      | subject        | description              |
      | Password Bug | Old description text     |

  Scenario: Successfully editing an existing ticket
    Given I am on the edit page for "Password Bug"
    When I fill in "Description" with "Updated description text"
    And I press "Update Ticket"
    Then I should see "Ticket was successfully updated"
    And I should see "Updated description text"
