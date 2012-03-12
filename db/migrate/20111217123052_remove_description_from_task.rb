class RemoveDescriptionFromTask < ActiveRecord::Migration
  def self.up
    remove_column :tasks, :description
  end

  def self.down
    add_column :tasks, :description, :text
  end
end
