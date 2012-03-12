class RemoveCreatedAtFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :created_at
  end

  def self.down
    add_column :projects, :created_at, :datetime
  end
end
