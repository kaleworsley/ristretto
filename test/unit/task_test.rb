require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  def setup
    @task = Task.new
  end

  test "should return valid states for select" do
    assert_equal 7, Task.states_for_select.length
  end

  test "should not save task without name" do
    assert !@task.save, "Saved task without name"
  end

  test "task duration" do
    user = User.find(:first)
    @task.name = 'blah'
    @task.project = Project.find(:first)
    @task.save

    ts1 = Timeslice.new
    ts1.started = '2010-04-03 08:00:00'
    ts1.finished = '2010-04-03 09:00:00'
    ts1.chargeable = true
    ts1.task = @task
    ts1.user = user
    ts1.description = 'blah'
    ts1.save

    ts2 = Timeslice.new
    ts2.started = '2010-04-03 09:00:00'
    ts2.finished = '2010-04-03 10:00:00'
    ts2.chargeable = true
    ts2.task = @task
    ts2.user = user
    ts2.description = 'blah'
    ts2.save

    assert_equal @task.duration.to_i, 7200, 'Task duration is 2 hours'
  end

  test "task duration by date" do
    user = User.find(:first)
    @task.name = 'blah'
    @task.project = Project.find(:first)
    @task.save

    ts1 = Timeslice.new
    ts1.started = '2010-04-04 09:00:00'
    ts1.finished = '2010-04-04 10:00:00'
    ts1.chargeable = true
    ts1.task = @task
    ts1.user = user
    ts1.description = 'blah'
    ts1.save

    assert_equal @task.duration(Date.parse('2010-04-04')), 3600, 'Task duration for 2010-04-04 is 1 hour'
  end

  test "task should have state not started by default" do
    assert_equal 'not_started', Task.new.state
  end

  test "task to s" do
    @task.name = 'test task'

    assert_equal @task.name, @task.to_s, 'Task.to_s should match the name'
  end

  # Return the list of states to which this task should logically progress
  test "should get next states" do
    assert_equal ['started'], @task.next_states
    @task.state = 'started'
    assert_equal ['delivered'], @task.next_states
    @task.state = 'delivered'
    assert_equal ['accepted','rejected'], @task.next_states
    @task.state = 'rejected'
    assert_equal ['started'], @task.next_states
    @task.state = 'accepted'
    assert_equal [], @task.next_states
    @task.state = 'duplicate'
    assert_equal [], @task.next_states
    @task.state = 'change_of_scope'
    assert_equal [], @task.next_states
  end

end
