class AddStateToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :state, :text
  end

  def self.down
    remove_column :tasks, :state
  end
end
