Feature: Teams management (sysadmin)
  As a sysadmin
  I want to create and manage teams

  Background:
    Given a sysadmin exists with email "sys@example.com"
    And I login as "sys@example.com"

  Scenario: Create and edit a team
    When I visit the teams index
    And I click "New Team"
    And I fill in "Name" with "Support"
    And I press "Create Team"
    Then I should see "Support"

    When I click "Edit"
    And I fill in "Description" with "Tier 1"
    And I press "Update Team"
    Then I should see "Tier 1"
