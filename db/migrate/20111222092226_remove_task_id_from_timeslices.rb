class RemoveTaskIdFromTimeslices < ActiveRecord::Migration
  def self.up
    remove_column :timeslices, :task_id
  end

  def self.down
    add_column :timeslices, :task_id, :integer
  end
end
