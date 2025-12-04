Feature: Customer service feedback on tickets
  As a requester
  I want to rate the customer service I received
  So that staff can see feedback on their tickets

  Background:
    Given a user "Alice" exists with role "user"
    And a staff user "Bob" exists with role "staff"

  Scenario: Requester sees feedback form for a resolved ticket
    Given a resolved ticket "Printer broken" requested by "Alice"
    And I am logged in as "Alice"
    When I visit the ticket page for "Printer broken"
    Then I should see "Customer Feedback"
    And I should see "How was the customer service you received on this ticket?"
    And I should see the rating stars for feedback

  Scenario: Requester submits a 5-star rating with feedback
    Given a resolved ticket "VPN issue" requested by "Alice"
    And I am logged in as "Alice"
    When I visit the ticket page for "VPN issue"
    And I rate the ticket "VPN issue" with 5 stars and feedback "Great support, very responsive"
    Then I should see "Thanks for your feedback"
    And I should see "★★★★★"
    And I should see "Great support, very responsive"

  Scenario: Requester cannot rate an unresolved ticket
    Given an open ticket "Cannot login" requested by "Alice"
    And I am logged in as "Alice"
    When I visit the ticket page for "Cannot login"
    Then I should see "Customer Feedback"
    And I should not see "How was the customer service you received on this ticket?"

  Scenario: A different user cannot access someone else's ticket
    Given a resolved ticket "Email problem" requested by "Alice"
    And a user "Charlie" exists with role "user"
    And I am logged in as "Charlie"
    When I attempt to visit the ticket page for "Email problem"
    Then I should be unauthorized

  Scenario: Staff member can see rating and feedback on the ticket show page
    Given a resolved ticket "Laptop issue" requested by "Alice" with rating 4 and feedback "Good but slow"
    And I am logged in as "Bob"
    When I visit the ticket page for "Laptop issue"
    Then I should see "Customer Feedback"
    And I should see "★★★★☆"
    And I should see "Good but slow"

  Scenario: Staff member sees rating on tickets index
    Given a resolved ticket "VPN performance" requested by "Alice" with rating 3 and feedback "OK"
    And I am logged in as "Bob"
    When I visit the tickets index
    Then I should see "VPN performance"
    And I should see "★★★☆☆" within the ticket card for "VPN performance"

  Scenario: Unrated tickets do not show a rating badge on index
    Given an open ticket "New feature request" requested by "Alice"
    And I am logged in as "Bob"
    When I visit the tickets index
    Then I should see "New feature request"
    And I should not see "★★★★★"
