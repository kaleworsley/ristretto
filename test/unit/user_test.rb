require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "user to s" do
    user = Factory.create(:user)

    assert_equal user.full_name, user.to_s, "User.to_s should match the full name"
  end

  test "paginate" do
    assert_equal User.find(:all, :limit => 50), User.page(nil)
  end

  test "minute step" do
    assert_equal users(:user1).minute_step, 15
  end

  test "projects" do
    assert_instance_of Array, users(:user1).projects
    assert_equal 1, users(:user1).projects.count
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

  test "name for sorted select box" do
    @user = Factory.create(:user, :full_name => 'Bob Fossil', :email => 'bob@zooniverse.com')
    assert_equal 'Bob Fossil (bob@zooniverse.com)', @user.for_select_box
  end
end
