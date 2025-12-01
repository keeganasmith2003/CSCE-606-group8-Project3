Feature: Kanban-style Tickets Board
  As a user, I want to view tickets laid out in columns by their status so I can see work at a glance

  Background:
    Given there is an agent named "TestAgent"

  Scenario: Viewing tickets on the board
    Given the following tickets exist:
      | subject           | description       | status      | priority | category             | requester_email      |
      | Fix login bug     | login failing     | open        | high     | Technical Issue      | alice@example.com    |
      | Work on API       | implement endpoint| in_progress | medium   | Technical Issue      | bob@example.com      |
    When I am logged in as agent "TestAgent"
    And I go to the tickets board page
    Then I should see "Open"
    And I should see "In Progress"
    And I should see "Fix login bug"
    And I should see "Work on API"

  Scenario: Column grouping and empty columns
    Given the following tickets exist:
      | subject           | description       | status      | priority | category             | requester_email      |
      | Task A             | first task        | open        | medium   | Technical Issue      | c@example.com        |
      | Task B             | second task       | open        | low      | Technical Issue      | d@example.com        |
      | Task C             | third task        | in_progress | high     | Account Access       | e@example.com        |
    When I am logged in as agent "TestAgent"
    And I go to the tickets board page
    Then I should see "Open"
    And I should see "In Progress"
    And I should see "On Hold"
    And I should see "Resolved"
    And I should see "Task A" under the "Open" column
    And I should see "Task B" under the "Open" column
    And I should see "Task C" under the "In Progress" column
    And I should not see "Task A" under the "Resolved" column
