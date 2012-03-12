class AddPanelsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :panels, :text
  end

  def self.down
    remove_column :users, :panels
  end
end
