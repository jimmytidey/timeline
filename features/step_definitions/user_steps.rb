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
find_button(txt).node.values.include? txt
end

#TODO the popup is completly invisible to rack-test (non-js) and selenium,
# drivers as the popup is the result of a click event sent via new.js.erb, 
# and not one of the selenium actions directly. Modification of selenium 
# may be required to get this working.

