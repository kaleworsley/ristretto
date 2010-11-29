Feature: Authentication
  In order to use ristretto
  As a non staff user
  I want to register, login, recover passwords and edit my profile

  Scenario: Login message
    Given I am not logged in
    When I go to the home page
    Then I should see "You must be logged in to view this page"

  Scenario: Register
    Given I am not logged in
    When I follow "Register"
    Then I fill in "Name" with "steve"
    And I fill in "First name" with "Steve"
    And I fill in "Last name" with "Smith"
    And I fill in "Password" with "1234"
    And I fill in "Password confirmation" with "1234"
    And I fill in "Email" with "steve@example.com"
    And I press "Save"
    Then I should see "User created"

  Scenario: Edit Profile
    Given staff user "steve@example.com" with password "1234"
    And I am logged in as "steve@example.com" with password "1234"
    When I follow "Edit Profile"
    And I fill in "Name" with "stan"
    And I press "Save"
    Then I should see "Profile updated"
    And I should see "stan"