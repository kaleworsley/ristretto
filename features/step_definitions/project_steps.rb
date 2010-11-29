Given /^I have ?a? projects? named (.+)$/ do |names|
  names.split(', ').each do |name|
    Factory.create(:project, :name => name)
  end
end

Given /^I have no projects$/ do
  Project.delete_all
end

Then /^I should have (\d+) projects$/ do |count|
  Project.count == count.to_i
end