class AddArAndApToTimeslice < ActiveRecord::Migration
  def self.up
    add_column :timeslices, :ar, :integer
    add_column :timeslices, :ap, :integer
  end

  def self.down
    remove_column :timeslices, :ap
    remove_column :timeslices, :ar
  end
end
