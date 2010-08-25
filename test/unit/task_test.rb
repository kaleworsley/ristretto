require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  def test_should_return_valid_states_for_select
    assert_equal 7, Task.states_for_select.length
  end

  def test_should_not_save_task_without_name
    task = Task.new
    assert !task.save, "Saved task without name"
  end

  def test_task_duration
    user = User.find(:first)
    task = Task.new
    task.name = 'blah'
    task.project = Project.find(:first)
    task.user = user
    task.assigned_to = user
    task.save

    ts1 = Timeslice.new
    ts1.started = '2010-04-03 08:00:00'
    ts1.finished = '2010-04-03 09:00:00'
    ts1.chargeable = true
    ts1.task = task
    ts1.user = user
    ts1.description = 'blah'
    ts1.save

    ts2 = Timeslice.new
    ts2.started = '2010-04-03 09:00:00'
    ts2.finished = '2010-04-03 10:00:00'
    ts2.chargeable = true
    ts2.task = task
    ts2.user = user
    ts2.description = 'blah'
    ts2.save

    assert_equal task.duration.to_i, 7200, 'Task duration is 2 hours'
  end

  def test_task_duration_by_date
    user = User.find(:first)
    task = Task.new
    task.name = 'blah'
    task.project = Project.find(:first)
    task.user = user
    task.assigned_to = user
    task.save

    ts1 = Timeslice.new
    ts1.started = '2010-04-04 09:00:00'
    ts1.finished = '2010-04-04 10:00:00'
    ts1.chargeable = true
    ts1.task = task
    ts1.user = user
    ts1.description = 'blah'
    ts1.save

    assert_equal task.duration(Date.parse('2010-04-04')), 3600, 'Task duration for 2010-04-04 is 1 hour'
  end

  def test_task_should_have_state_not_started_by_default
    assert_equal 'not_started', Task.new.state
  end

  def test_task_to_s
    task = Task.new
    task.name = 'test task'

    assert_equal task.name, task.to_s, 'Task.to_s should match the name'
  end
end
