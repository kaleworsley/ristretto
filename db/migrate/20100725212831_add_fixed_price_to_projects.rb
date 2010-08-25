class AddFixedPriceToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :fixed_price, :boolean
  end

  def self.down
    remove_column :projects, :fixed_price
  end
end
