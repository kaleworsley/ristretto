class RemoveWeightFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :weight
  end

  def self.down
    add_column :projects, :weight, :integer
  end
end
