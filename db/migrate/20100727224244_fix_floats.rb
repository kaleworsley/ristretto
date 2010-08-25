class FixFloats < ActiveRecord::Migration
  def self.up
    change_column :projects, :estimate, :decimal, :scale => 2, :precision => 10
    change_column :tasks, :estimate, :decimal, :scale => 2, :precision => 10
  end

  def self.down
    change_column :projects, :estimate, :float
    change_column :tasks, :estimate, :float
  end
end
