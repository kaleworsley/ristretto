Factory.define :user do |f|
  f.sequence(:full_name) { |n| "foo bar#{n}" }
  f.password "foobar"  
  f.password_confirmation { |u| u.password }  
  f.sequence(:email) { |n| "foo#{n}@example.com" } 
end

Factory.define :customer do |f|
  f.sequence(:name) { |n| "Customer #{n}" }
end

Factory.define :project do |f|
  f.sequence(:name) { |n| "foo#{n}" }
  f.association :customer, :factory => :customer
  f.state "current"
  f.kind "development"
  f.fixed_price false
  f.rate 130
  f.estimate 100
end

Factory.define :task do |f|
  f.association :project, :factory => :project
  f.sequence(:name) { |n| "foo#{n}" }
  f.state "started"
  f.estimate 4.5
end
