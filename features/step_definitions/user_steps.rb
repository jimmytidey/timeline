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

Given /^I am an authenticated administrator$/ do
  visit '/users/cuke' # create the user it he's not created
  user = User.find_by_name('rpxusername')
  user.admin = true
  user.save
end

Then /^I should see the button "([^"]*)"$/ do | label |
  find_button(label)
end

Then /^debug$/ do
  debugger;nil
end

Given /^some timelines have been created$/ do
  TimelineChart.all.should_not be_empty
end

