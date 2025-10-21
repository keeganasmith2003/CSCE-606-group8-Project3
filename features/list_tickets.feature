Feature: List Tickets
  As a user
  So that I can view my submitted requests
  I want to see a list of all tickets

  Background:
    Given the following tickets exist:
      | subject        | description           |
      | Login Issue  | Cannot access account |
      | Bug Report   | App crashes sometimes |

  Scenario: Viewing all submitted tickets
    When I go to the tickets list page
    Then I should see "Login Issue"
    And I should see "Bug Report"
