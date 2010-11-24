Feature: Manage Customers
  In order to manage customers
  As a staff user
  I want create, edit, delete, show and list customers

  Background:
    Given staff user "steve@example.com" with password "1234"
    And I am logged in as "steve@example.com" with password "1234"

  Scenario: Customers List
    Given I have customers named Customer 1, Customer 2
    When I go to the list of customers
    Then I should see "Customer 1"
    And I should see "Customer 2"
    
  Scenario: Create New Customer
    Given I have no customers
    And I am on the list of customers
    When I follow "New customer"
    And I fill in "Name" with "Customer 1"
    And I press "Save"
    Then I should see "Customer was successfully created."
    And I should see "Customer 1"
    And I should see "No Projects!"
    And I should have 1 customer

  Scenario: Edit Existing Customer
    Given I have a customer named Customer 1
    When I go to the list of customers
    And I follow "Customer 1"
    And I follow "Edit"
    And I fill in "Name" with "Customer 2"
    And I press "Save"
    Then I should see "Customer was successfully updated."
    And I should see "Customer 2"
    And I should see "No Projects!"
    And I should have 1 customer