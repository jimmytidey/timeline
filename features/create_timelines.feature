Feature: Create Timelines
  In order to manage timelines
  As a authenticated user
  I want to be able to cerate and edit timelines

	@selenium
  Scenario: A user can create a new timeline and add an event
    Given I am an authenticated user
    And I press "Add a new timeline"
    Then I should see "Edit Timeline Chart"
    And "timeline_chart_title" should by filled out with "Untitled"
    When I fill in "Title" with "The last 50 years in computing"
    And I fill in "Start Year" with "1960" within "#edit_timeline_chart"
    And I fill in "End Year" with "2010" within "#edit_timeline_chart"
		And I press "Save"
		And I fill in "Event" with "Great Fire of London" within "#new_event"
    And I fill in "Start date" with "1960" within "#new_event"
    And I fill in "End date" with "2000" within "#new_event"
    And I press "Create Event"
#   Then I should see "Great Fire of London" #on the timeline
