class AddDefaultWeightToTask < ActiveRecord::Migration
  def self.up
    change_column_default :tasks, :weight, 0
  end

  def self.down
    change_column_default :tasks, :weight, nil
  end
end
