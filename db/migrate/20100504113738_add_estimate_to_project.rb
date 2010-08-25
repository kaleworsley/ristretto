class AddEstimateToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :estimate, :integer
  end

  def self.down
    remove_column :projects, :estimate
  end
end
