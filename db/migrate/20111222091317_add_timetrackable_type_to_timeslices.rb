class AddTimetrackableTypeToTimeslices < ActiveRecord::Migration
  def self.up
    add_column :timeslices, :timetrackable_type, :string
  end

  def self.down
    remove_column :timeslices, :timetrackable_type
  end
end
