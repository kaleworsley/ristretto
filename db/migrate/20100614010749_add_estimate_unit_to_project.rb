class AddEstimateUnitToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :estimate_unit, :string
  end

  def self.down
    remove_column :projects, :estimate_unit
  end
end
