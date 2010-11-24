Given /^staff user "([^"]*)" with password "([^"]*)"$/ do |email, password|
  Factory.create(:user, :email => email, :password => password, :is_staff => true)
end

Given /^I am logged in as "([^"]*)" with password "([^"]*)"$/ do |email, password|
  visit login_url
  fill_in "Email", :with => email
  fill_in "Password", :with => password
  click_button "Login" 
end
