Feature: Assign Ticket (with teams)
  As an agent or sysadmin
  So that I can manage ticket responsibilities
  I want to assign tickets to teams and/or agents

  Background:
    Given there is a team named "Support"
    And there is a team named "Ops"
    And there is an agent named "Alice" in team "Support"
    And there is an agent named "Bob" in team "Support"
    And there is a requester named "Charlie"
    And I am logged in as agent "Alice"

  # --- Manual assignment including team ---

  Scenario: Manually assign a ticket to a team and agent
    Given there is an unassigned ticket created by "Charlie"
    When I visit the ticket page
    And I select "Support" from the team dropdown
    And I select "Bob" from the agent dropdown
    And I press "Assign" within the assignment form
    Then I should see one of:
      | Ticket assigned to Bob     |
      | Ticket assignment updated. |
    And the ticket should be assigned to "Bob"
    And the ticket's team should be "Support"

  # --- Assign to team only (no specific agent yet) ---

  Scenario: Assign only to a team (leave agent unassigned)
    Given there is an unassigned ticket created by "Charlie"
    When I visit the ticket page
    And I select "Support" from the team dropdown
    And I leave the agent dropdown unassigned
    And I press "Assign" within the assignment form
    Then I should see "Ticket assignment updated."
    And the ticket's team should be "Support"

  # --- Re-route to a different team ---

  Scenario: Reassign ticket to a different team (misrouted)
    Given there is an unassigned ticket created by "Charlie"
    And the ticket is currently assigned to team "Support" and agent "Bob"
    When I visit the ticket page
    And I select "Ops" from the team dropdown
    And I leave the agent dropdown unassigned
    And I press "Update Assignment" within the assignment form
    Then I should see "Ticket assignment updated."
    And the ticket's team should be "Ops"

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
