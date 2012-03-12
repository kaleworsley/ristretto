class AddTimetrackableIdToTimeslices < ActiveRecord::Migration
  def self.up
    add_column :timeslices, :timetrackable_id, :integer
  end

  def self.down
    remove_column :timeslices, :timetrackable_id
  end
end
