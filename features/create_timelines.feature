Feature: Create Timelines
  In order to manage timelines
  As a authenticated user
  I want to be able to cerate and edit timelines

	@javascript
  Scenario: A user can create a new timeline and add an event
    Given I am an authenticated user
    And I go to create a new timeline
    Then I should see "Edit Timeline Chart"
    And I "timeline_chart_title" should by filled out with "Untitled"
    When I fill in "Title" with "The last 50 years in computing"
    And I select "1960" from "timeline_chart_start_date_1i"
    And I select "2010" from "timeline_chart_end_date_1i"
		And I press "Save"
		And I fill in "Event" with "Great Fire of London" within "#new_event"
    And I fill in "Start date" with "1960" within "#new_event"
    And I fill in "End date" with "1700" within "#new_event"
    And I press "Create Event"
#   Then I should see "Great Fire of London" #on the timeline
