class AddKindToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :kind, :string, :default => 'development'
  end

  def self.down
    remove_column :projects, :kind
  end
end
