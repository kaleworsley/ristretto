class RemoveCreatedAtFromCustomers < ActiveRecord::Migration
  def self.up
    remove_column :customers, :created_at
  end

  def self.down
    add_column :customers, :created_at, :datetime
  end
end
