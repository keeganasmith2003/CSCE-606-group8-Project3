Feature: User login with Google
  As a visitor
  I want to sign in with Google
  So I can use the app and see role-based nav

  Background:
    Given OmniAuth is in test mode
    And I am on the home page
  Scenario: Guest sees a login button
    Given I am on the home page
    Then I should see "Login with Google"

  Scenario: First-time sign in creates a user and logs in
    Given the Google mock returns uid "123", email "first@example.com", name "First User"
    When I click "Login with Google"
    Then I should see "Signed in as First User"
    And I should see "First User" in the navbar
    And the app should have exactly 1 user with email "first@example.com"


  Scenario: Sysadmin sees Users link in navbar after login
    Given there is a sysadmin in the database with email "root@example.com" named "Root"
    And the Google mock returns uid "root-1", email "root@example.com", name "Root"
    When I click "Login with Google"
    Then I should see "Users" in the navbar

  Scenario: Logout clears session
    Given the Google mock returns uid "bye-1", email "bye@example.com", name "Bye User"
    And I click "Login with Google"
    When I press "Log out"
    Then I should see "Signed out."
    And I should see "Login with Google"

