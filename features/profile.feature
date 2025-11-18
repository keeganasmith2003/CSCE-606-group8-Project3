Feature: User profile
  In order to view my account information
  As an authenticated user
  I want to visit my profile page

  Background:
  Scenario: View my profile after signing in with Google
    Given I log in with Google as uid "12345", email "testuser@example.com", name "Test User"
    When I click "Test User"
    Then I should be on the profile page
    And I should see "Test User"
    And I should see "testuser@example.com"
