Feature: Authentication
  In order to create timelines
  As a user
  I want to be able to authenicate
 
  Scenario: A guest wants to create a timeline
    Given I am a guest
    When I go to the home page
    Then I should see the button "Sign in"
    And I should see the button "Add a new timeline"

  Scenario: User can log-out
    Given I am an authenticated user
    Then I should see the button "Log out"
    When I press "Log out"
    Then I should see "Signed out successfully"
    And I should be on the home page

  Scenario: Can't list users without password
    Given I don't know the admin password
    When I go to list the users
    Then I should not see "Listing users:"

# Await resolution of issue 34 below:
# http://code.google.com/p/selenium/issues/detail?id=34
#
#  Scenario: Admin signs in
#    Given I know the admin password
#    When I go to list the users
#    Then I should see "Listing users:"

