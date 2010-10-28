Given /^I am a guest$/ do
  visit('/')
  within('#user_nav') do
    if page.has_content?('Sign out') then
      click_button('Sign out')
    end
  end
end

Given /^I am an authenticated user$/ do
  visit '/users/cuke'
  Then %{I should see "Signed in successfully"}
end

Then /^I should see the button "([^"]*)"$/ do | label |
  txt = label
  find_button(txt).native.attributes['value'].value
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
