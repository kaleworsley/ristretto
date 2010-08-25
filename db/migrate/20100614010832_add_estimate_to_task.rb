class AddEstimateToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :estimate, :integer
  end

  def self.down
    remove_column :tasks, :estimate
  end
end
