require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def test_full_name
    user = User.new
    user.first_name = 'Test'
    user.last_name = 'User'

    assert_equal 'Test User', user.full_name, "Fullname is 'Test User'"
  end

  def test_user_to_s
    user = User.new
    user.first_name = 'Test'
    user.last_name = 'User'

    assert_equal user.full_name, user.to_s, "User.to_s should match the full name"
  end

  def test_is_staff
    user = User.new
    user.is_staff = true

    assert user.is_staff?, "User is staff"
  end

  def test_assigned_tasks
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

  def test_paginate
    assert_equal User.find(:all, :limit => 50), User.page(nil)
  end

  def test_minute_step
    assert_equal users(:user1).minute_step, 15
  end

  def test_initials
    assert_equal "TU", users(:user1).initials
  end

  def test_all_projects
    assert_instance_of Array, users(:user1).all_projects
    assert_equal 3, users(:user1).all_projects.count
  end

  def test_is_staff_should_be_protected
    users(:user2).update_attributes({:is_staff => true})
    assert !users(:user2).is_staff
  end

  def test_should_return_current_projects
    assert_instance_of Array, users(:user1).current_projects
    assert_equal 1, users(:user1).current_projects.count
  end

  def test_should_return_current_projects_ids
    assert_instance_of Array, users(:user1).current_projects_ids
    assert_equal [projects(:project1).id], users(:user1).current_projects_ids
  end

  def test_should_return_current_projects_timeslices
    timeslices =  users(:user1).current_projects_timeslices
    assert_instance_of Array, timeslices
    assert_equal 3, timeslices.count
    assert_equal timeslices(:timeslice1), timeslices[0]

    timeslices =  users(:user1).current_projects_timeslices(:order => 'started DESC')
    assert_instance_of Array, timeslices
    assert_equal timeslices(:timeslice3), timeslices[0], 'should apply extra conditions'
  end

  def test_should_return_current_projects_recent_timeslices
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
