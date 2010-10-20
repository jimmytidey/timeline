Given /^I am a guest$/ do
  visit('/')
  within('#user_nav') do
    if page.has_content?('Sign out') then
      click_button('Sign out')
    end
  end
end

#Given /^I am an authenticated user$/ do
#  RPXNow.expects(:user_data).with("123456").returns({:email => 'rpxuser@email.com',:identifier => 'test',:username => 'rpxusername'})
#  post(url_for(:action => 'create', :controller => 'users', :token => '123456')) #Add user to db. capybara will lose cookie
#  pp User.find(1)
#
#  debugger
#
#  post(url_for(:action => 'create', :controller => 'users', :token => '123456'))
#  Then %{show me the page}
#end

Then /^I should see the button "([^"]*)"$/ do | label |
  txt = label
  find_button(txt).node.values.include? txt
end

#TODO the popup is completly invisible to rack-test (non-js) and selenium,
       # drivers as the popup is the result of a click event sent via new.js.erb, 
       # and not one of the selenium actions directly. Modification of selenium 
       # may be required to get this working.

