class RemoveIsStaffFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :is_staff
  end

  def self.down
    add_column :users, :is_staff, :boolean
  end
end
