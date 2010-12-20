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
  f.association :user, :factory => :user
end

Factory.define :project do |f|
  f.sequence(:name) { |n| "foo#{n}" }
  f.association :user, :factory => :user
  f.association :customer, :factory => :customer
  f.state "current"
  f.kind "development"
  f.fixed_price false
  f.rate 130
  f.estimate 100
  f.estimate_unit "hours"
end

Factory.define :task do |f|
  f.association :project, :factory => :project
  f.association :user, :factory => :user
  f.sequence(:name) { |n| "foo#{n}" }
  f.state "started"
  f.estimate 4.5
  f.assigned_to {|t| t.association(:stakeholder, :project => t.project).user }
end

Factory.define :unassigned_task, :parent => :task do |t|
  t.assigned_to nil
  t.state "not_started"
end

Factory.define :stakeholder do |f|
  f.association :user, :factory => :user
  f.association :project, :factory => :project
end
