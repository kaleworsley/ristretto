class ChangeEstimatesIntoFloats < ActiveRecord::Migration
  def self.up
    change_column :projects, :estimate, :float, :scale => 2, :precision => 10
    change_column :tasks, :estimate, :float, :scale => 2, :precision => 10
  end

  def self.down
    change_column :projects, :estimate, :integer
    change_column :tasks, :estimate, :integer
  end
end
