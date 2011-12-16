class RemoveDeadlineFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :deadline
  end

  def self.down
    add_column :projects, :deadline, :date
  end
end
