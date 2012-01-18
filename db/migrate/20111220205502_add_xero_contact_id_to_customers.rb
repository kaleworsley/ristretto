class AddXeroContactIdToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :xero_contact_id, :string
  end

  def self.down
    remove_column :customers, :xero_contact_id
  end
end
