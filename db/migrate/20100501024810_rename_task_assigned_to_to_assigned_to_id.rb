class RenameTaskAssignedToToAssignedToId < ActiveRecord::Migration
  def self.up
    rename_column :tasks, :assigned_to, :assigned_to_id
  end

  def self.down
    rename_column :tasks, :assigned_to_id, :assigned_to
  end
end
