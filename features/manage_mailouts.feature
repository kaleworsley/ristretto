Feature: Manage mailouts
  In order to send notifications to customers
  As a staff user
  I want to create and send mailouts

  Background:
    Given only the following users exist:
      | first_name  | last_name | email               | password  | is_staff  |
      | Joe         | Staff     | staff@staff.com     | 1234      | true      |
      | Joe         | Public    | user1@notstaff.com  | 1234      | false     |
      | Jane        | Public    | user2@notstaff.com  | 1234      | false     |
    And I am logged in as "staff@staff.com" with password "1234"

  Scenario: Send a mailout to everyone
    When I go to the mailouts page
    And fill in "Subject" with "Important notice"
    And fill in "Body" with "This is an important notice"
    And check "Send to all users"
    And I press "Send"
    Then I should see "Mailout sent to 3 users"
    And "staff@staff.com" should receive 1 email
    And "user1@notstaff.com" should receive 1 email
    And "user2@notstaff.com" should receive 1 email

  Scenario: Send a mailout to selected users
    When I go to the mailouts page
    And fill in "Subject" with "Important notice"
    And fill in "Body" with "This is an important notice"
    And select "Public, Joe (user1@notstaff.com)" from "Users"
    And I press "Send"
    Then I should see "Mailout sent to 1 user"
    And "user1@notstaff.com" should receive 1 email
    And "staff@staff.com" should receive no emails
    And "user2@notstaff.com" should receive no emails
