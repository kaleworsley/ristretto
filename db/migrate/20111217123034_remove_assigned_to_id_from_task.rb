class RemoveAssignedToIdFromTask < ActiveRecord::Migration
  def self.up
    remove_column :tasks, :assigned_to_id
  end

  def self.down
    add_column :tasks, :assigned_to_id, :integer
  end
end
