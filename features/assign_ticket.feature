Feature: Assign Ticket
  As an agent or admin
  So that I can manage ticket responsibilities
  I want to assign tickets to agents

  Background:
    Given there is an agent named "Alice"
    And there is an agent named "Bob"
    And there is a requester named "Charlie"
    And I am logged in as agent "Alice"

  Scenario: Manually assign a ticket to an agent
    Given there is an unassigned ticket created by "Charlie"
    When I visit the ticket page
    And I select "Bob" from the agent dropdown
    And I press "Assign" within the assignment form
    Then I should see "Ticket assigned to Bob"
    And the ticket should be assigned to "Bob"

  Scenario: Auto-assign ticket on creation when round-robin is enabled
    Given the assignment strategy is set to "round_robin"
    When "Charlie" creates a new ticket
    Then the ticket should be automatically assigned to "Alice"
    When "Charlie" creates another new ticket
    Then the ticket should be automatically assigned to "Bob"

  Scenario: No auto-assign when round-robin is disabled
    Given the assignment strategy is set to "manual"
    When "Charlie" creates a new ticket
    Then the ticket should remain unassigned