class AddRateToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :rate, :float, :scale => 2, :precision => 10
  end

  def self.down
    remove_column :projects, :rate
  end
end
