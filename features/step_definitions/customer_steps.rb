Given /^I have ?a? customers? named (.+)$/ do |names|
  names.split(', ').each do |name|
    Factory.create(:customer, :name => name)
  end
end

Given /^I have no customers$/ do
  Customer.delete_all
end

Then /^I should have (\d+) customer$/ do |count|
  Customer.count == count.to_i
end