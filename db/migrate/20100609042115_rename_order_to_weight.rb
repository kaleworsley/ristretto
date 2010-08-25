class RenameOrderToWeight < ActiveRecord::Migration
  def self.up
    rename_column :projects, :order, :weight
    rename_column :tasks, :order, :weight
  end

  def self.down
    rename_column :projects, :weight, :order
    rename_column :tasks, :weight, :order
  end
end
