Feature: Create Ticket
  As a user
  So that I can request help
  I want to create a new support ticket with a title and description

  Scenario: Successfully creating a new ticket
    Given I am on the new ticket page
    When I fill in "Title" with "Login issue"
    And I fill in "Description" with "Cannot access my account"
    And I press "Create Ticket"
    Then I should see "Ticket was successfully created"
    When I go to the tickets list page
    Then I should see "Login issue" in the ticket list

