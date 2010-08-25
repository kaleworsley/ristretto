class AddUserIdToTimeslice < ActiveRecord::Migration
  def self.up
    add_column :timeslices, :user_id, :integer
  end

  def self.down
    remove_column :timeslices, :user_id
  end
end
