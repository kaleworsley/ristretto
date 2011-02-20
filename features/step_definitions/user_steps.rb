Given /^staff user "([^"]*)" with password "([^"]*)"$/ do |email, password|
  Factory.create(:user, :email => email, :password => password, :is_staff => true)
end

Given /^I am logged in as "([^"]*)" with password "([^"]*)"$/ do |email, password|
  visit login_url
  fill_in "Email", :with => email
  fill_in "Password", :with => password
  click_button "Login" 
end

Given /^I am not logged in$/ do
  visit logout_url
end

Given /^the following users exist:$/ do |user_table|
  user_table.hashes.each do |user_hash|
    Factory.create(:user, user_hash)
  end
end

# FIXME - Currently need this to remove the user fixtures
# before running.  When running plain 'rake', the fixtures
# are loaded prior to running cucumber, and so the fixture
# users are present and break some features.  This can be
# removed once fixtures have been fully replaced by Factory
# Girl.
Given /^only the following users exist:$/ do |user_table|
  User.delete_all
  Given "the following users exist:", user_table
end

