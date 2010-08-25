class AddIsStaffToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_staff, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_staff
  end
end
