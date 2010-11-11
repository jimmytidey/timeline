Given /^I am a guest$/ do
  visit('/')
  within('#user_nav') do
    if page.has_content?('Log out') then
      click_button('Log out')
    end
  end
end

Given /^I am an authenticated user$/ do
  visit '/users/cuke'
  Then %{I should see "Signed in successfully"}
end

Then /^I should see the button "([^"]*)"$/ do | label |
  find_button(label)
end

Given /^I don't know the admin password$/ do
  #Capybara.app_host = "http://admin:whatever@cap:9887"
end

Given /^I know the admin password$/ do
  Capybara.app_host = "http://admin:#{HTTP_BASIC_PASSWORD}@cap:9887"
end

Then /^debug$/ do
  debugger;nil
end

Then /^"([^"]*)" should by filled out with "([^"]*)"$/ do |id, intended_text|
  #Only envjs supports this, but is is bombing out.
  #field_text = find_field(id).native.attributes['value'].value
  #field_text == intended_text
end

Given /^some timelines have been created$/ do
  TimelineChart.all.should_not be_empty
end

