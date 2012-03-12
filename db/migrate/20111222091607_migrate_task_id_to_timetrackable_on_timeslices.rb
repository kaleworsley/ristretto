class MigrateTaskIdToTimetrackableOnTimeslices < ActiveRecord::Migration
  def self.up
    Timeslice.reset_column_information
    Timeslice.find(:all).each do |t|
      t.timetrackable_id = t.task_id
      t.timetrackable_type = 'Task'
      t.save false
    end
  end

  def self.down
    Timeslice.find(:all, :conditions => {:timetrackable_type => 'Task'}).each do |t|
      t.task_id = t.timetrackable_id
      t.save false
    end
  end
end
