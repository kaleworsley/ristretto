class RemoveUpdatedAtFromCustomers < ActiveRecord::Migration
  def self.up
    remove_column :customers, :updated_at
  end

  def self.down
    add_column :customers, :updated_at, :datetime
  end
end
