Feature: Authentication
  In order to create timelines
  As a user
  I want to be able to authenicate
 
  Scenario: A guest wants to create a timeline
    Given I am a guest
    When I go to the home page
    Then I should see the button "Sign in"
    And I should see "Sign in to add your timeline"

  Scenario: User can log-out
    Given I am an authenticated user
    Then I should see the button "Log out"
    When I press "Log out"
    Then I should see "Signed out successfully"
    And I should be on the home page

  Scenario: A guest can't get into admin area
    Given I am a guest
    When I go to the admin area
    Then I should see "Please login first."

  Scenario: A non admin user can't get into admin area 
    Given I am an authenticated user
    When I go to the admin area
    Then I should see "Please login first."

  Scenario: Admin signs in
    Given I am an authenticated administrator
    When I go to the admin area
    Then I should see "Admin Area"

