Feature: Create Timelines
  In order to manage timelines
  As a authenticated user
  I want to be able to cerate and edit timelines

  Scenario: A user can create a new timeline and add an event
    Given I am an authenticated user
    And I go to create a new timeline
    And I fill in "Title" with "The last 50 years in computing"
Then show me the page
    And I select "1960" from "timeline_chart_start_date_1i"
    And I select "2010" from "timeline_chart_end_date_1i"
		And I press "Create timeline"
    And I fill in "Start" with "1960" within "new_event"
#    And I fill in "End" with "1700"
#    And I click "Save"
#		And I fill in "Event Name" with "Great Fire of London"
#		And I fill in "Start" with "1660"
#		And I fill in "Duration" with "1"
#    And I click "Add"
#    Then I should see "Great Fire of London" #on the timeline
