class RemoveApFromTimeslices < ActiveRecord::Migration
  def self.up
    remove_column :timeslices, :ap
  end

  def self.down
    add_column :timeslices, :ap, :integer
  end
end
