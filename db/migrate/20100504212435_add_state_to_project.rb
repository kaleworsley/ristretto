class AddStateToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :state, :string
  end

  def self.down
    remove_column :projects, :state
  end
end
