class AddStageToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :stage, :string
  end

  def self.down
    remove_column :tasks, :stage
  end
end
