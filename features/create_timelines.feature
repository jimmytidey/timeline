Feature: Create Timelines
  In order to manage timelines
  As a authenticated user
  I want to be able to cerate and edit timelines

	@selenium
  Scenario: A user can create a new timeline and add an event
    Given I am an authenticated user
    And I press "Add a new timeline"
    Then I should see "Now add some events to your timeline."
    When I fill in "Title" with "The last 50 years in computing"
    And I fill in "Centre year" with "1970" within "#edit_timeline_chart"
		And I press "Save"
		And I fill in "event[title]" with "GNU Project" within "#new_event"
    And I fill in "event[start_year]" with "1984" within "#new_event"
    And I fill in "event[end_year]" with "2000" within "#new_event"
    And I press "Add »"
    Then I should see "GNU Project" within "#my-timeline"
		And I should see "Added an event."
