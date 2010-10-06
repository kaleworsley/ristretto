require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "full name" do
    user = User.new
    user.first_name = 'Test'
    user.last_name = 'User'

    assert_equal 'Test User', user.full_name, "Fullname is 'Test User'"
  end

  test "user to s" do
    user = User.new
    user.first_name = 'Test'
    user.last_name = 'User'

    assert_equal user.full_name, user.to_s, "User.to_s should match the full name"
  end

  test "is staff" do
    user = User.new
    user.is_staff = true

    assert user.is_staff?, "User is staff"
  end

  test "assigned tasks" do
    user = users(:user1)
    assert_equal 1,user.assigned_tasks.count
    task = Task.new
    task.name = 'blah'
    task.project = Project.find(:first)
    task.user = user
    task.assigned_to = user
    task.save
    assert_equal 2,user.assigned_tasks.count
  end

  test "paginate" do
    assert_equal User.find(:all, :limit => 50), User.page(nil)
  end

  test "minute step" do
    assert_equal users(:user1).minute_step, 15
  end

  test "initials" do
    assert_equal "TU", users(:user1).initials
  end

  test "all projects" do
    assert_instance_of Array, users(:user1).all_projects
    assert_equal 3, users(:user1).all_projects.count
  end

  test "is staff should be protected" do
    users(:user2).update_attributes({:is_staff => true})
    assert !users(:user2).is_staff
  end

  test "should return current projects" do
    assert_instance_of Array, users(:user1).current_projects
    assert_equal 1, users(:user1).current_projects.count
  end

  test "should return current projects ids" do
    assert_instance_of Array, users(:user1).current_projects_ids
    assert_equal [projects(:project1).id], users(:user1).current_projects_ids
  end

  test "should return current projects timeslices" do
    timeslices =  users(:user1).current_projects_timeslices
    assert_instance_of Array, timeslices
    assert_equal 3, timeslices.count
    assert_equal timeslices(:timeslice1), timeslices[0]

    timeslices =  users(:user1).current_projects_timeslices(:order => 'started DESC')
    assert_instance_of Array, timeslices
    assert_equal timeslices(:timeslice3), timeslices[0], 'should apply extra conditions'
  end

  test "should return current projects recent timeslices" do
    timeslices =  users(:user1).current_projects_recent_timeslices
    assert_instance_of Array, timeslices
    assert_equal 3, timeslices.count
    assert_equal timeslices(:timeslice3), timeslices[0], 'should be in reverse date order'

    timeslices =  users(:user1).current_projects_recent_timeslices(1)
    assert_instance_of Array, timeslices
    assert_equal 1, timeslices.count, 'should apply a limit'
    assert_equal timeslices(:timeslice3), timeslices[0], 'should be in reverse date order'
  end

  test "should be able to ignore mail from a project" do
    user = users(:user1)
    assert user.ignore_mail_from(projects(:project1))
    assert user.ignore_mail_from?(projects(:project1))
  end

  test "should be able to ignore mail from a task" do
    user = users(:user1)
    assert user.ignore_mail_from(tasks(:task1))
    assert user.ignore_mail_from?(tasks(:task1))
  end

  test "should be able to receive mail from a project" do
    user = users(:user1)
    assert user.ignore_mail_from(projects(:project1))
    assert user.ignore_mail_from?(projects(:project1))

    assert user.receive_mail_from(projects(:project1))
    assert user.receive_mail_from?(projects(:project1))
  end

  test "should be able to receive mail from a task" do
    user = users(:user1)
    assert user.ignore_mail_from(tasks(:task1))
    assert user.ignore_mail_from?(tasks(:task1))

    assert user.receive_mail_from(tasks(:task1))
    assert user.receive_mail_from?(tasks(:task1))
  end
end
