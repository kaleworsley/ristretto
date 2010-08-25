class AddAssignedToToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :assigned_to, :integer
  end

  def self.down
    remove_column :tasks, :assigned_to
  end
end
