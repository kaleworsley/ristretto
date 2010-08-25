class AddDefaultWeightToProject < ActiveRecord::Migration
  def self.up
    change_column_default :projects, :weight, 0
  end

  def self.down
    change_column_default :projects, :weight, nil
  end
end
