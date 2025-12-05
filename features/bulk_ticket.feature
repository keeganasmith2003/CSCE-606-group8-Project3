Feature: Bulk close and delete tickets
  As a staff member
  I want to bulk close or delete tickets
  So that I can manage large volumes of tickets efficiently

  Background:
    Given there is an agent named "TestAgent"

  # -----------------------------
  # BOARD: BULK CLOSE
  # -----------------------------
  Scenario: Staff bulk-closes tickets from the board
    Given the following tickets exist:
      | subject           | description        | status      | priority | category        | requester_email    |
      | Fix login bug     | login failing      | open        | high     | Technical Issue | alice@example.com  |
      | Work on API       | implement endpoint | open        | medium   | Technical Issue | bob@example.com    |
      | Already resolved  | was fixed          | resolved    | low      | Technical Issue | carol@example.com  |
    When I am logged in as agent "TestAgent"
    And I go to the tickets board page
    And I select the ticket "Fix login bug" for bulk actions
    And I select the ticket "Work on API" for bulk actions
    And I choose "Close selected" from the "Bulk action" select
    And I press "Apply"
    Then the ticket "Fix login bug" should have status "resolved"
    And the ticket "Work on API" should have status "resolved"
    And the ticket "Already resolved" should have status "resolved"

  # -----------------------------
  # BOARD: BULK DELETE
  # -----------------------------
  Scenario: Staff bulk-deletes tickets from the board
    Given the following tickets exist:
      | subject           | description        | status | priority | category        | requester_email   |
      | Old ticket A      | old issue A        | open   | low      | Technical Issue | dave@example.com  |
      | Old ticket B      | old issue B        | open   | low      | Technical Issue | erin@example.com  |
      | Keep this ticket  | should stay        | open   | medium   | Technical Issue | frank@example.com |
    When I am logged in as agent "TestAgent"
    And I go to the tickets board page
    And I select the ticket "Old ticket A" for bulk actions
    And I select the ticket "Old ticket B" for bulk actions
    And I choose "Delete selected" from the "Bulk action" select
    And I press "Apply"
    Then I should not see "Old ticket A"
    And I should not see "Old ticket B"
    And I should see "Keep this ticket"

  # -----------------------------
  # BOARD: NO TICKETS SELECTED
  # -----------------------------
  Scenario: Staff tries to run a bulk action with no tickets selected
    Given the following tickets exist:
      | subject       | description  | status | priority | category        | requester_email   |
      | Single ticket | just one     | open   | medium   | Technical Issue | gary@example.com  |
    When I am logged in as agent "TestAgent"
    And I go to the tickets board page
    And I choose "Close selected" from the "Bulk action" select
    And I press "Apply"
    Then I should see "No tickets selected."
    And the ticket "Single ticket" should have status "open"

  # -----------------------------
  # DASHBOARD: BULK CLOSE
  # -----------------------------
  Scenario: Staff bulk-closes tickets from their dashboard
    Given the following tickets exist:
      | subject           | description        | status      | priority | category        | requester_email    |
      | Dashboard ticket  | visible on dash    | open        | high     | Technical Issue | alice@example.com  |
    And ticket "Dashboard ticket" is assigned to agent "TestAgent"
    When I am logged in as agent "TestAgent"
    And I go to my tickets dashboard page
    And I select the ticket "Dashboard ticket" for bulk actions
    And I choose "Close selected" from the "Bulk action" select
    And I press "Apply"
    Then the ticket "Dashboard ticket" should have status "resolved"

  # -----------------------------
  # PERMISSIONS: REGULAR USER
  # -----------------------------
  Scenario: Regular requester cannot see bulk actions on the board
    Given the following tickets exist:
      | subject           | description   | status | priority | category        | requester_email       |
      | User ticket       | some issue    | open   | medium   | Technical Issue | requester@example.com |
    And there is a requester named "PlainUser" with email "requester@example.com"
    When I am logged in as requester "PlainUser"
    And I go to the tickets board page
    Then I should not see "Bulk action:"
    And I should not see "Close selected"
    And I should not see "Delete selected"
