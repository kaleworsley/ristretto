class RemoveUpdatedAtFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :updated_at
  end

  def self.down
    add_column :projects, :updated_at, :datetime
  end
end
