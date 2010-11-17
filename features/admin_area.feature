Feature: Admin area
  In order to administer the sites data
  As an admin
  I want to be user the admin area
 
  Scenario: Administer Timelines
    Given I am an authenticated administrator
    When I go to the admin area
    Then I should see "Sort by hits"
    And I should see "Sort by date created"
    And I should see "Sort by date edited"
    And I should see "User"
    And I should see "1"
    When I follow "1"
    Then I should see "User Info"

  Scenario: Administer Users
    Given I am an authenticated administrator
    When I go to the admin area
    Then I should see "Administer Users"
		When I follow "Administer Users"
    Then I should see "User List"
