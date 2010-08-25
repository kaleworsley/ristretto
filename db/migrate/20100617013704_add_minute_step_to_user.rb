class AddMinuteStepToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :minute_step, :integer, :default => 15
  end

  def self.down
    remove_column :users, :minute_step
  end
end
