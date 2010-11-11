Feature: View timelines
  In order to view timelines
  As a guest
  I want to be able to view timelines created by users
 
  Scenario: A guest can view top timelines
    Given I am a guest
    And some timelines have been created
    When I go to the home page
    Then I should see "Already built"
    When I follow "Show" within "#top_timelines"
		Then I should see "The Last 50 Years in Computing"
