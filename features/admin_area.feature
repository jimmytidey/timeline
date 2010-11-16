Feature: Admin area
  In order to administer the sites data
  As an admin
  I want to be user the admin area
 
@wip
  Scenario: Admin lists
    Given I am an authenticated administrator
    When I go to the admin area
    Then I should see "Sort by hits"
    Then I should see "Sort by date created"
    Then I should see "Sort by date updates"
