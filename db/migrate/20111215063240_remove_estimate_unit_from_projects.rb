class RemoveEstimateUnitFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :estimate_unit
  end

  def self.down
    add_column :projects, :estimate_unit, :string
  end
end
