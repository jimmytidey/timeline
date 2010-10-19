Given /^I am a guest$/ do
  visit('/')
  within('#user_nav') do
    if page.has_content?('Sign out') then
      click_button('Sign out')
    end
  end
end

Then /^I should see the button "([^"]*)"$/ do | label |
  page.should have_selector('add_timeline')
end
