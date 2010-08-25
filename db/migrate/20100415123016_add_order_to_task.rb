class AddOrderToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :order, :integer
  end

  def self.down
    remove_column :tasks, :order
  end
end
