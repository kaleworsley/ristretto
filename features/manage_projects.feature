Feature: Manage Projects
  In order to manage projects
  As a staff user
  I want create, edit, delete, show and list projects

  Background:
    Given staff user "steve@example.com" with password "1234"
    And I am logged in as "steve@example.com" with password "1234"

  Scenario: Projects List
    Given I have projects named Project 1, Project 2
    When I go to the list of projects
    Then I should have 2 projects
    And I should see "Project 1"
    And I should see "Project 2"

    Scenario: Create New Project
      Given I have no projects
      And I have a customer named Customer 1
      When I go to the list of customers
      And I follow "Customer 1"
      And I follow "New project"
      And I fill in "Name" with "Project 1"
      And I fill in "State" with "Current"
      And I fill in "Kind" with "Development"