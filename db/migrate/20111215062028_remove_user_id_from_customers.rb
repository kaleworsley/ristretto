class RemoveUserIdFromCustomers < ActiveRecord::Migration
  def self.up
    remove_column :customers, :user_id
  end

  def self.down
    add_column :customers, :user_id, :integer
  end
end
