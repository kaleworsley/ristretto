require 'test_helper'

class TimesliceTest < ActiveSupport::TestCase

  def test_timeslices_by_task_id
    user = User.find(:first)
    task = Task.new
    task.name = 'blah'
    task.project = Project.find(:first)
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

    assert_equal Timeslice.by_task_ids(task.id), [ts1, ts2], 'Timeslices by task id'
  end


    def test_timeslices_duration
    user = User.find(:first)
    task = Task.new
    task.name = 'blah'
    task.project = Project.find(:first)
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

    assert_equal Timeslice.total_duration([ts1, ts2]), 7200, 'Timeslices duration'
  end

    def test_timeslice_chargeable_duration
    user = User.find(:first)
    task = Task.new
    task.name = 'blah'
    task.project = Project.find(:first)
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
    ts2.chargeable = false
    ts2.task = task
    ts2.user = user
    ts2.description = 'blah'
    ts2.save

    assert_equal Timeslice.total_chargeable_duration([ts1, ts2]), 3600, 'Timeslices chargeable duration'
  end

    def test_timeslice_duration_in_hours
    user = User.find(:first)
    task = Task.new
    task.name = 'blah'
    task.project = Project.find(:first)
    task.save

    ts1 = Timeslice.new
    ts1.started = '2010-04-03 08:00:00'
    ts1.finished = '2010-04-03 09:00:00'
    ts1.chargeable = true
    ts1.task = task
    ts1.user = user
    ts1.description = 'blah'
    ts1.save

    assert_equal ts1.duration_in_hours, 1, 'Timeslice duration in hours'
  end

  def test_should_not_save_without_user
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:00:00'
    timeslice.finished = '2009-11-15 12:00:00'
    assert !timeslice.save, "Saved timeslice without user"
  end

  def test_should_not_save_timeslice_with_finished_before_or_equal_to_started
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 12:00:00'
    timeslice.finished = '2009-11-15 11:00:00'
    assert !timeslice.save, "Saved timeslice with finished before started"
    timeslice.started = timeslice.finished
    assert !timeslice.save, "Saved timeslice with finished equal to started"
  end

  def test_should_return_timeslice_duration_in_seconds
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:00:00'
    timeslice.finished = '2009-11-15 12:00:00'
    assert_equal 3600, timeslice.duration, "Duration is 3600 seconds"
  end

  def test_should_return_time_only
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:00:00'
    timeslice.finished = '2009-11-15 12:00:00'
    assert_equal '11:00', timeslice.started_time, "Started time 11:00:00"
    assert_equal '12:00', timeslice.finished_time, "Finished time 12:00:00"
  end

  def test_should_set_time
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:59:59'
    timeslice.finished = '2009-11-15 12:59:59'
    timeslice.started_time = '11:00'
    timeslice.finished_time = '12:00'
    assert_equal '11:00', timeslice.started_time, "Started time set to 11:00:00"
    assert_equal '12:00', timeslice.finished_time, "Finished time set to 12:00:00"
  end

  def test_should_fail_invalid_set_time
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:59:59'
    timeslice.finished = '2009-11-15 12:59:59'
    timeslice.started_time = '25:00'
    timeslice.finished_time = '26:00'
    assert_equal '11:59', timeslice.started_time, "Started time fail"
    assert_equal '12:59', timeslice.finished_time,"Finished time fail"
  end

  def test_should_return_next
    timeslice1 = Timeslice.new
    timeslice1.user = users(:user1)
    timeslice1.started = '2009-11-14 13:00:00'
    timeslice1.finished = '2009-11-14 14:00:00'
    timeslice1.save

    timeslice2 = Timeslice.new
    timeslice2.user = users(:user1)
    timeslice2.started = '2009-11-14 14:00:00'
    timeslice2.finished = '2009-11-14 15:00:00'
    timeslice2.save

    assert_equal timeslice1.next(), timeslice2, 'Returns next'
  end

  def test_should_return_previous
    timeslice1 = Timeslice.new
    timeslice1.user = users(:user1)
    timeslice1.started = '2009-11-14 13:00:00'
    timeslice1.finished = '2009-11-14 14:00:00'
    timeslice1.save

    timeslice2 = Timeslice.new
    timeslice2.user = users(:user1)
    timeslice2.started = '2009-11-14 14:00:00'
    timeslice2.finished = '2009-11-14 15:00:00'
    timeslice2.save

    assert_equal timeslice2.previous(), timeslice1, 'Returns previous'
  end

  def test_should_save_contiguous_with_another
    timeslice = Timeslice.new
    timeslice.user = users(:user1)
    timeslice.started = '2009-11-14 13:00:00'
    timeslice.finished = '2009-11-14 14:00:00'
    assert timeslice.save, "Saved with start time same as existing timeslice finish time"
    timeslice.started = '2009-11-14 11:00:00'
    timeslice.finished = '2009-11-14 12:00:00'
    assert timeslice.save, "Saved with finished time same as existing timeslice start time"
  end

  # Should be able to change just the date of a timeslice
  def test_should_change_date
    timeslice = Timeslice.new
    timeslice.user = users(:user1)
    timeslice.started = '2009-11-14 13:00:00'
    timeslice.finished = '2009-11-14 14:00:00'
    assert_equal Date.parse('2009-11-14'), timeslice.date
    timeslice.date = Date.parse('2009-12-15')
    assert_equal Date.parse('2009-12-15'), timeslice.date
    assert_equal Time.zone.parse('2009-12-15 13:00:00'), timeslice.started
    assert_equal Time.zone.parse('2009-12-15 14:00:00'), timeslice.finished
    # Should accept a string aswell as a Date object
    timeslice.date = '2009-12-25'
    assert_equal Date.parse('2009-12-25'), timeslice.date
    assert_equal Time.zone.parse('2009-12-25 13:00:00'), timeslice.started
    assert_equal Time.zone.parse('2009-12-25 14:00:00'), timeslice.finished
  end

  def test_should_compare_date
    t1 = Timeslice.new
    t1 = Timeslice.new
    t1.user = users(:user2)
    t1.started = '2009-11-14 00:00:00'
    t1.finished = '2009-11-14 00:15:00'

    t2 = Timeslice.new
    t2.user = users(:user2)
    t2.started = '2009-11-14 23:30:00'
    t2.finished = '2009-11-14 23:45:00'

    assert_equal true, t1.same_day_as?(t2),
      "returns true when comparing timeslices on the same day"

    t2 = Timeslice.new
    t2.user = users(:user2)
    t2.started = '2009-11-13 23:30:00'
    t2.finished = '2009-11-13 23:45:00'

    assert_equal false, t1.same_day_as?(t2),
      "returns false when comparing timeslices on different days"

  end

end
