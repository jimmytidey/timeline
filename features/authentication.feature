Feature: Authentication
  In order to create timelines
  As a user
  I want to be able to authenicate
 
  Scenario: A guest wants to create a timeline
    Given I am a guest
    When I go to the home page
    Then I should see the button "Sign in"
    And I should see the button "Add a new timeline"

# TODO
#
# 
#
#  Scenario: User can log-out
#    Given I am an authenticated user
#    Then I should see the button "Log out"
#    When I press "Log out"
#    Then I should see "Signed out successfully"
#    And I should be at the home page

#  Scenario: Admin signs in
#    Given I am signed in as admin
#    Then I can delete user accounts
#    And I can delete timelines
