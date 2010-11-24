Factory.define :user do |f|
  f.sequence(:name) { |n| "foo#{n}" }
  f.sequence(:first_name) { |n| "foo#{n}" }
  f.sequence(:last_name) { |n| "bar#{n}" }
  f.password "foobar"  
  f.password_confirmation { |u| u.password }  
  f.sequence(:email) { |n| "foo#{n}@example.com" } 
end

Factory.define :customer do |f|
  f.sequence(:name) { |n| "Customer #{n}" }
  f.user Factory.create(:user)
end
