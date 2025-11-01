Feature: Navbar Teams link
  As a user
  I want the navbar to show Teams appropriately

  Background:
    Given a sysadmin exists with email "sys@example.com"
    And a staff user exists with email "staff@example.com"
    And a team "Support" exists
    And "staff@example.com" is a member of team "Support"

  Scenario: Sysadmin sees Teams index link
    When I login as "sys@example.com"
    And I visit the home page
    Then I should see a link "Teams" pointing to the teams index

  Scenario: Staff sees their team link
    When I login as "staff@example.com"
    And I visit the home page
    Then I should see a link "Support" pointing to that team page
